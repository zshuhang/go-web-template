package database

import (
	"fmt"
	"go-web-template/internal/config"
	"gorm.io/driver/mysql"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func NewDB(cfg *config.Config) (*gorm.DB, error) {
	var db *gorm.DB
	var err error

	dbCfg := cfg.Database

	switch cfg.Database.Driver {
	case "mysql":
		dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=True&loc=%s", dbCfg.User, dbCfg.Password, dbCfg.Host, dbCfg.Port, dbCfg.DBName, dbCfg.TimeZone)
		db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	case "postgres":
		dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%d sslmode=%s", dbCfg.Host, dbCfg.User, dbCfg.Password, dbCfg.DBName, dbCfg.Port, dbCfg.SSLMode)
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	default:
		return nil, fmt.Errorf("unsupported database driver: %s", dbCfg.Driver)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	return db, err
}
