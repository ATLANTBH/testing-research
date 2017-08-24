package com.atlantbh.jenkins.owlReporter.model;

public class TestRun {
    private Long id;
    private TestSuite testSuite;
    private String gitHash;
    private String gitBranch;
    private String build;

    public TestRun(Long id, TestSuite testSuite, String gitHash, String gitBranch, String build) {
        this.id = id;
        this.testSuite = testSuite;
        this.gitHash = gitHash;
        this.gitBranch = gitBranch;
        this.build = build;
    }

    public TestRun() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public TestSuite getTestSuite() {
        return testSuite;
    }

    public void setTestSuite(TestSuite testSuite) {
        this.testSuite = testSuite;
    }

    public String getGitHash() {
        return gitHash;
    }

    public void setGitHash(String gitHash) {
        this.gitHash = gitHash;
    }

    public String getGitBranch() {
        return gitBranch;
    }

    public void setGitBranch(String gitBranch) {
        this.gitBranch = gitBranch;
    }

    public String getBuild() {
        return build;
    }

    public void setBuild(String build) {
        this.build = build;
    }
}
