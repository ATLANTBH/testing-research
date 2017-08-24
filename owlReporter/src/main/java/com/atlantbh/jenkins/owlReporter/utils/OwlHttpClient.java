package com.atlantbh.jenkins.owlReporter.utils;

import com.atlantbh.jenkins.owlReporter.model.TestRun;
import com.atlantbh.jenkins.owlReporter.model.TestSuite;
import com.google.gson.Gson;
import okhttp3.*;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.File;
import java.io.IOException;

public class OwlHttpClient {

    private MediaType JSON = MediaType.parse("application/json; charset=utf-8");
    private String owlUrl;
    private OkHttpClient client;

    private final static String TEST_RUNS = "/api/v1/test-runs";
    private final static String TEST_SUITES = "api/v1/test-suites";
    private final static String UPLOAD_XML = "/api/v1/test-runs/%d/test-cases/junit-xml-report";

    public OwlHttpClient(String owlUrl) {
        this.owlUrl = owlUrl;
        this.client = new OkHttpClient();
    }

    public Long getTestSuiteId(String name) throws IOException {
        Request request = new Request.Builder()
                .url(owlUrl + TEST_SUITES)
                .build();

        try (Response response = client.newCall(request).execute()) {
            JSONParser parser = new JSONParser();
            try {
                JSONObject testSuitesObj = (JSONObject) parser.parse(response.body().string());
                JSONArray testSuites = (JSONArray) testSuitesObj.get("content");
                for(int i = 0; i < testSuites.size(); i++) {
                    JSONObject testSuite = ((JSONObject) testSuites.get(i));

                    if(testSuite.get("suite").equals(name)) {
                        return (Long) testSuite.get("id");
                    }
                }
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public Long createTestSuite(String json) throws IOException {
        RequestBody body = RequestBody.create(JSON, json);
        Request request = new Request.Builder()
                .url(owlUrl + TEST_SUITES)
                .post(body)
                .build();
        try (Response response = client.newCall(request).execute()) {
            Gson gson = new Gson();
            TestSuite testSuite = gson.fromJson(response.body().string(), TestSuite.class);
            return testSuite.getId();
        }
    }

    public Long createTestRun(String json) throws IOException {
        RequestBody body = RequestBody.create(JSON, json);
        Request request = new Request.Builder()
                .url(owlUrl + TEST_RUNS)
                .post(body)
                .build();
        try (Response response = client.newCall(request).execute()) {
            Gson gson = new Gson();
            TestRun testRun = gson.fromJson(response.body().string(), TestRun.class);
            return testRun.getId();
        }
    }

    public Integer uploadXml(File file, Long testRunId) throws IOException {
        RequestBody requestBody = new MultipartBody.Builder()
                .addFormDataPart("file", file.getName(),
                        RequestBody.create(MediaType.parse("application/x-www-form-urlencoded"), file))
                .build();

        Request request = new Request.Builder()
                .url(owlUrl + String.format(UPLOAD_XML, testRunId))
                .post(requestBody)
                .build();

        try (Response response = client.newCall(request).execute()) {
            return response.code();
        }
    }
}
