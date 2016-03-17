# Description of zypper repositories

require 'puppet/util/inifile'

module Puppet
  # A property for one entry in a .ini-style file
  class IniProperty < Puppet::Property
    def insync?(is)
      # A should property of :absent is the same as nil
      if is.nil? && should == :absent
        return true
      end
      super(is)
    end

    def sync
      if safe_insync?(retrieve)
        result = nil
      else
        result = set(self.should)
        if should == :absent
          resource.section[inikey] = nil
        else
          resource.section[inikey] = should
        end
      end
      result
    end

    def retrieve
      resource.section[inikey]
    end

    def inikey
      name.to_s
    end

    # Set the key associated with this property to KEY, instead
    # of using the property's NAME
    def self.inikey(key)
      # Override the inikey instance method
      # Is there a way to do this without resorting to strings ?
      # Using a block fails because the block can't access
      # the variable 'key' in the outer scope
      self.class_eval("def inikey ; \"#{key.to_s}\" ; end")
    end

  end

  # Doc string for properties that can be made 'absent'
  ABSENT_DOC="Set this to `absent` to remove it from the file completely."

  newtype(:zypprepo) do
    @doc = "The client-side description of a zypper repository. Repository
      configurations are found by parsing `/etc/zypp/zypper.conf` and
      the files indicated by the `reposdir` option in that file
      (see `zypper(8)` for details).

      Most parameters are identical to the ones documented
      in the `zypper(8)` man page.

      Continuation lines that zypper supports (for the `baseurl`, for example)
      are not supported. This type does not attempt to read or verify the
      exinstence of files listed in the `include` attribute."

    class << self
      attr_accessor :filetype
      # The writer is only used for testing, there should be no need
      # to change zypperconf or inifile in any other context
      attr_accessor :zypperconf
      attr_writer :inifile
    end

    self.filetype = Puppet::Util::FileType.filetype(:flat)

    @inifile = nil

    @zypperconf = "/etc/zypp/zypper.conf"

    # Where to put files for brand new sections
    @defaultrepodir = nil

    def self.instances
      l = []
      check = validproperties
      clear
      inifile.each_section do |s|
        next if s.name == "main"
        obj = new(:name => s.name, :audit => check)
        current_values = obj.retrieve
        obj.eachproperty do |property|
          if current_values[property].nil?
            obj.delete(property.name)
          else
            property.should = current_values[property]
          end
        end
        obj.delete(:audit)
        l << obj
      end
      l
    end

    # Return the Puppet::Util::IniConfig::File for the whole zypper config
    def self.inifile
      if @inifile.nil?
        @inifile = read
        main = @inifile['main']
        raise Puppet::Error, "File #{zypperconf} does not contain a main section" if main.nil?
        reposdir = main['reposdir']
        reposdir ||= "/etc/zypp/repos.d"
        reposdir.gsub!(/[\n,]/, " ")
        reposdir.split.each do |dir|
          Dir::glob("#{dir}/*.repo").each do |file|
            @inifile.read(file) if File.file?(file)
          end
        end
        reposdir.split.each do |dir|
          if File::directory?(dir) && File::writable?(dir)
            @defaultrepodir = dir
            break
          end
        end
      end
      @inifile
    end

    # Parse the zypper config files. Only exposed for the tests
    # Non-test code should use self.inifile to get at the
    # underlying file
    def self.read
      result = Puppet::Util::IniConfig::File.new
      result.read(zypperconf)
      main = result['main']
      raise Puppet::Error, "File #{zypperconf} does not contain a main section" if main.nil?
      reposdir = main['reposdir']
      reposdir ||= "/etc/zypp/repos.d"
      reposdir.gsub!(/[\n,]/, " ")
      reposdir.split.each do |dir|
        Dir::glob("#{dir}/*.repo").each do |file|
          result.read(file) if File.file?(file)
        end
      end
      if @defaultrepodir.nil?
        reposdir.split.each do |dir|
          if File::directory?(dir) && File::writable?(dir)
            @defaultrepodir = dir
            break
          end
        end
      end
      result
    end

    # Return the Puppet::Util::IniConfig::Section with name NAME
    # from the zypper config
    def self.section(name)
      result = inifile[name]
      if result.nil?
        # Brand new section
        path = zypperconf
        path = File::join(@defaultrepodir, "#{name}.repo") unless @defaultrepodir.nil?
        Puppet::info "create new repo #{name} in file #{path}"
        result = inifile.add_section(name, path)
      end
      result
    end

    # Store all modifications back to disk
    def self.store
      inifile.store
      unless Puppet[:noop]
        target_mode = 0644 # FIXME: should be configurable
        inifile.each_file do |file|
          current_mode = File.stat(file).mode & 0777
          unless current_mode == target_mode
            Puppet::info "changing mode of #{file} from %03o to %03o" % [current_mode, target_mode]
            File.chmod(target_mode, file)
          end
        end
      end
    end

    # This is only used during testing.
    def self.clear
      @inifile = nil
      @zypperconf = "/etc/zypp/zypper.conf"
      @defaultrepodir = nil
    end

    # Return the Puppet::Util::IniConfig::Section for this zypprepo resource
    def section
      self.class.section(self[:name])
    end

    # Store modifications to this zypprepo resource back to disk
    def flush
      self.class.store
    end

    newparam(:name) do
      desc "The name of the repository.  This corresponds to the
        `repositoryid` parameter in `zypper(8)`."
      isnamevar
    end

    newproperty(:descr, :parent => Puppet::IniProperty) do
      desc "A human-readable description of the repository.
        This corresponds to the name parameter in `zypper(8)`.
        #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(/.*/) { }
      inikey "name"
    end

    newproperty(:mirrorlist, :parent => Puppet::IniProperty) do
      desc "The URL that holds the list of mirrors for this repository.
        #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(/.*/) { }
    end

    newproperty(:baseurl, :parent => Puppet::IniProperty) do
      desc "The URL for this repository. #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      # Should really check that it's a valid URL
      newvalue(/.*/) { }
    end

    newproperty(:path, :parent => Puppet::IniProperty) do
      desc "The path relative to the baseurl. #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(/.*/) { }
    end

    newproperty(:enabled, :parent => Puppet::IniProperty) do
      desc "Whether this repository is enabled, as represented by a
        `0` or `1`. #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(%r{(0|1)}) { }
    end

    newproperty(:gpgcheck, :parent => Puppet::IniProperty) do
      desc "Whether to check the GPG signature on packages installed
        from this repository, as represented by a `0` or `1`.
        #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(%r{(0|1)}) { }
    end

    newproperty(:gpgkey, :parent => Puppet::IniProperty) do
      desc "The URL for the GPG key with which packages from this
        repository are signed. #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      # Should really check that it's a valid URL
      newvalue(/.*/) { }
    end

    newproperty(:priority, :parent => Puppet::IniProperty) do
      desc "Priority of this repository from 1-99. #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(%r{[1-9][0-9]?}) { }
    end

    newproperty(:autorefresh, :parent => Puppet::IniProperty) do
      desc "Enable autorefresh of the repository, as represented by a
        `0` or `1`. #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(%r{(0|1)}) { }
    end

    newproperty(:keeppackages, :parent => Puppet::IniProperty) do
      desc "Enable RPM files caching, as represented by a
        `0` or `1`. #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(%r{(0|1)}) { }
    end

    newproperty(:type, :parent => Puppet::IniProperty) do
      desc "The type of software repository. Values can match
         `yast2` or `rpm-md` or `plaindir` or `yum`. #{ABSENT_DOC}"
      newvalue(:absent) { self.should = :absent }
      newvalue(%r{yast2|rpm-md|plaindir|yum}) { }
    end

  end
end
