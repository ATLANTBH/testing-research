package org.javamcp.helpers;

import org.javamcp.Application;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class EnvironmentProperties {
    private final Properties properties = new Properties();

    public EnvironmentProperties() {
        this("qa");
    }

    public EnvironmentProperties(String environment) {
        if (!"qa".equals(environment) && !"staging".equals(environment)) {
            throw new IllegalArgumentException("environment must be one of: qa, staging.");
        }
        try (InputStream environmentalPropFile = Application.class
                    .getClassLoader()
                    .getResourceAsStream(environment + ".properties")) {
            if (environmentalPropFile == null) {
                throw new IllegalArgumentException("Missing environment configuration: " + environment + ".properties");
            }
            this.properties.load(environmentalPropFile);
        } catch (IOException ioException) {
            throw new IllegalArgumentException("Unable to load environment configuration: " + environment + ".properties", ioException);
        }
    }

    public String loadProp(String property) {
        return this.properties.getProperty(property);
    }

    public String loadEnvOrProp(String property) {
        String value = System.getenv(property);
        return value == null || value.isBlank() ? loadProp(property) : value;
    }
}
