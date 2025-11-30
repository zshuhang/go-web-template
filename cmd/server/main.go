package main

import (
	"fmt"
	"go-web-template/internal/config"
	"go-web-template/internal/database"
)

func main() {
	fmt.Println("主服务 Hello World")

	cfg, _ := config.LoadConfig()
	db, _ := database.NewDB(cfg)

	fmt.Println(db)
}
