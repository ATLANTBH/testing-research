package com.atlantbh.jenkins.owlReporter;

import hudson.model.AbstractBuild;
import hudson.model.Action;

public class OwlReporterBuildAction implements Action {
    private final static String DISPLAY_NAME = "Owl report";
    private final static String ICON_FILE_NAME = "/plugin/owlReporter/img/owl.png";
    private final static String TEST_RUN_URI = "/test-runs/%d/test-cases";

    private AbstractBuild<?, ?> build;
    private String owlUrl;

    public String getOwlUrl() {
        return owlUrl;
    }

    public Long getTestRunId() {
        return testRunId;
    }

    private Long testRunId;

    @Override
    public String getIconFileName() {
        return ICON_FILE_NAME;
    }

    @Override
    public String getDisplayName() {
        return DISPLAY_NAME;
    }

    @Override
    public String getUrlName() {
        return owlUrl + String.format(TEST_RUN_URI, testRunId);
    }

    public AbstractBuild<?, ?> getBuild() {
        return build;
    }

    OwlReporterBuildAction(final AbstractBuild<?, ?> build, String owlUrl, Long testRunId)
    {
        this.build = build;
        this.owlUrl = owlUrl;
        this.testRunId = testRunId;
    }
}
