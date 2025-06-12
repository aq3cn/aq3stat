package main

import (
	"log"
	"os"

	"aq3stat/internal/api"
	"aq3stat/migrations"
	"aq3stat/pkg/database"
	"aq3stat/pkg/logger"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	err := godotenv.Load("./configs/.env")
	if err != nil {
		log.Println("Error loading .env file, using environment variables")
	}

	// Initialize logger
	logger.InitLogger()

	// Initialize database
	database.InitDB()

	// Run migrations
	migrations.Migrate()

	// Set Gin mode
	if os.Getenv("ENV") == "production" {
		gin.SetMode(gin.ReleaseMode)
	} else {
		gin.SetMode(gin.DebugMode)
	}

	// Create Gin router
	router := gin.Default()

	// Setup routes
	api.SetupRoutes(router)

	// Get port from environment variable
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8080"
	}

	// Start server
	log.Printf("Server starting on port %s", port)
	err = router.Run(":" + port)
	if err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
