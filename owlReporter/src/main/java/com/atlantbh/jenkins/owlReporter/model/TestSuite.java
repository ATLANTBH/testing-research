package com.atlantbh.jenkins.owlReporter.model;

import com.google.gson.annotations.SerializedName;

public class TestSuite {
    @SerializedName("suite")
    private String name;
    private Long id;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public TestSuite(String name, Long id) {
        this.name = name;
        this.id = id;
    }

    public TestSuite() {
    }
}
