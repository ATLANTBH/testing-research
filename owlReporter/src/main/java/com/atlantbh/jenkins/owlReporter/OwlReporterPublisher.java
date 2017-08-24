package com.atlantbh.jenkins.owlReporter;
import com.atlantbh.jenkins.owlReporter.model.TestRun;
import com.atlantbh.jenkins.owlReporter.model.TestSuite;
import com.atlantbh.jenkins.owlReporter.utils.OwlHttpClient;
import com.google.gson.Gson;
import hudson.Launcher;
import hudson.Extension;
import hudson.model.*;
import hudson.tasks.*;
import hudson.util.FormValidation;
import org.apache.tools.ant.DirectoryScanner;
import net.sf.json.JSONObject;
import org.kohsuke.stapler.DataBoundConstructor;
import org.kohsuke.stapler.StaplerRequest;
import org.kohsuke.stapler.QueryParameter;

import javax.servlet.ServletException;
import java.io.File;
import java.io.IOException;

/**
 * Sample {@link Builder}.
 *
 * <p>
 * When the user configures the project and enables this builder,
 * {@link DescriptorImpl#newInstance(StaplerRequest)} is invoked
 * and a new {@link OwlReporterPublisher} is created. The created
 * instance is persisted to the project configuration XML by using
 * XStream, so this allows you to use instance fields (like {@link #files})
 * to remember the configuration.
 *
 * <p>
 * When a build is performed, the {@link #perform} method will be invoked.
 *
 * @author Kohsuke Kawaguchi
 */
public class OwlReporterPublisher extends Recorder {
    private final static String GIT_COMMIT_ENV = "GIT_COMMIT";
    private final static String GIT_BRANCH_ENV = "GIT_BRANCH";

    private final String files;
    private final String suiteName;
    private final String owlUrl;

    // Fields in config.jelly must match the parameter names in the "DataBoundConstructor"
    @DataBoundConstructor
    public OwlReporterPublisher(String files, String suiteName, String owlUrl) {
        this.files = files;
        this.suiteName = suiteName;
        this.owlUrl = owlUrl;
    }

    /**
     * We'll use this from the {@code config.jelly}.
     */
    public String getFiles() {
        return files;
    }
    public String getSuiteName() {
        return suiteName;
    }
    public String getOwlUrl() {
        return owlUrl;
    }

    @Override
    public boolean perform(AbstractBuild build, Launcher launcher, BuildListener listener) {
        OwlHttpClient owlHttpClient = new OwlHttpClient(getOwlUrl());
        try {
            Long suiteId = owlHttpClient.getTestSuiteId(getSuiteName());

            if (suiteId == null) {
                TestSuite newTestSuite = new TestSuite();
                newTestSuite.setName(suiteName);
                Gson gson = new Gson();
                suiteId = owlHttpClient.createTestSuite(gson.toJson(newTestSuite));
            }


            try {
                String gitHash = build.getEnvironment(listener).get(GIT_COMMIT_ENV);
                String gitBranch = build.getEnvironment(listener).get(GIT_BRANCH_ENV);

                TestSuite testSuite = new TestSuite(suiteName, suiteId);
                TestRun testRun = new TestRun(0L ,testSuite, gitHash, gitBranch, Integer.toString(build.number));

                Long testRunId;

                Gson gson = new Gson();

                System.out.println(gson.toJson(testRun));
                testRunId = owlHttpClient.createTestRun(gson.toJson(testRun));

                String[] files = getResultFiles(getFiles());

                for (String file : files) {
                    File xmlFile = new File(file);
                    owlHttpClient.uploadXml(xmlFile, testRunId);
                }


                OwlReporterBuildAction buildAction = new OwlReporterBuildAction(build, getOwlUrl(), testRunId);
                build.addAction(buildAction);

            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return true;
    }

    private String[] getResultFiles(String path) {
        DirectoryScanner scanner = new DirectoryScanner();

        scanner.setIncludes(new String[]{path});
        scanner.setCaseSensitive(false);
        scanner.scan();

        return scanner.getIncludedFiles();
    }


    // Overridden for better type safety.
    // If your plugin doesn't really define any property on Descriptor,
    // you don't have to do this.
    @Override
    public DescriptorImpl getDescriptor() {
        return (DescriptorImpl)super.getDescriptor();
    }

    @Override
    public BuildStepMonitor getRequiredMonitorService() {
        return BuildStepMonitor.NONE;
    }

    /**
     * Descriptor for {@link OwlReporterPublisher}. Used as a singleton.
     * The class is marked as public so that it can be accessed from views.
     *
     * <p>
     * See {@code src/main/resources/hudson/plugins/hello_world/OwlPublisher/*.jelly}
     * for the actual HTML fragment for the configuration screen.
     */
    @Extension // This indicates to Jenkins that this is an implementation of an extension point.
    public static final class DescriptorImpl extends BuildStepDescriptor<Publisher> {
        /**
         * To persist global configuration information,
         * simply store it in a field and call save().
         *
         * <p>
         * If you don't want fields to be persisted, use {@code transient}.
         */
        // private boolean useFrench;

        /**
         * In order to load the persisted global configuration, you have to
         * call load() in the constructor.
         */
        public DescriptorImpl() {
            load();
        }

        /**
         * Performs on-the-fly validation of the form field 'files'.
         *
         * @param value
         *      This parameter receives the value that the user has typed.
         * @return
         *      Indicates the outcome of the validation. This is sent to the browser.
         *      <p>
         *      Note that returning {@link FormValidation#error(String)} does not
         *      prevent the form from being saved. It just means that a message
         *      will be displayed to the user.
         */
        public FormValidation doCheckFiles(@QueryParameter String value)
                throws IOException, ServletException {
            if (value.length() == 0)
                return FormValidation.error("Please set a path");
            return FormValidation.ok();
        }

        public FormValidation doCheckSuiteName(@QueryParameter String value)
                throws IOException, ServletException {
            if (value.length() == 0)
                return FormValidation.error("Please set a suite ID");
            return FormValidation.ok();
        }

        public FormValidation doCheckOwlUrl(@QueryParameter String value)
                throws IOException, ServletException {
            if (value.length() == 0)
                return FormValidation.error("Please set a URL");
            return FormValidation.ok();
        }

        public boolean isApplicable(Class<? extends AbstractProject> aClass) {
            // Indicates that this builder can be used with all kinds of project types
            return true;
        }

        /**
         * This human readable files is used in the configuration screen.
         */
        public String getDisplayName() {
            return "Publish test results to owl";
        }

        @Override
        public boolean configure(StaplerRequest req, JSONObject formData) throws FormException {
            // To persist global configuration information,
            // set that to properties and call save().
            // useFrench = formData.getBoolean("useFrench");
            // ^Can also use req.bindJSON(this, formData);
            //  (easier when there are many fields; need set* methods for this, like setUseFrench)
            save();
            return super.configure(req,formData);
        }

        /**
         * This method returns true if the global configuration says we should speak French.
         *
         * The method files is bit awkward because global.jelly calls this method to determine
         * the initial state of the checkbox by the naming convention.
         */
//        public boolean getUseFrench() {
//            return useFrench;
//        }

    }
}

