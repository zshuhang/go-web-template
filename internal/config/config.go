package config

import (
	"fmt"
	"github.com/spf13/viper"
	"strings"
)

type Config struct {
	Server   ServerConfig   `yaml:"server"`
	Database DatabaseConfig `yaml:"database"`
	// Log      LogConfig      `yaml:"log"`
}

type ServerConfig struct {
	Address string `yaml:"address"`
}

type DatabaseConfig struct {
	Driver   string `yaml:"driver"`
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	User     string `yaml:"user"`
	Password string `yaml:"password"`
	DBName   string `yaml:"dbname"`
	TimeZone string `yaml:"timezone"` // for mysql
	SSLMode  string `yaml:"sslmode"`  // for postgres
}

func LoadConfig() (*Config, error) {
	viper.AddConfigPath("./config")
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")

	viper.SetEnvPrefix("APP")
	viper.AutomaticEnv()
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_", "-", "_"))

	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			return nil, fmt.Errorf("config file not found at ./config/config.yaml")
		} else {
			return nil, fmt.Errorf("error reading config file: %w", err)
		}
	}

	var config Config
	if err := viper.Unmarshal(&config); err != nil {
		return nil, fmt.Errorf("unable to decode config into struct: %w", err)
	}

	return &config, nil
}
