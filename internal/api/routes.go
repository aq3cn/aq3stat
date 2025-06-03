package api

import (
	"github.com/gin-gonic/gin"
	"aq3stat/internal/middleware"
)

// SetupRoutes sets up all API routes
func SetupRoutes(router *gin.Engine) {
	// Apply global middleware
	router.Use(middleware.CORSMiddleware())

	// Create controllers
	authController := NewAuthController()
	userController := NewUserController()
	websiteController := NewWebsiteController()
	collectorController := NewCollectorController()

	// Health check endpoint
	router.GET("/api/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "healthy",
			"service": "aq3stat-backend",
		})
	})

	// Public routes
	router.POST("/api/auth/login", authController.Login)
	router.POST("/api/auth/register", authController.Register)

	// Tracking routes (no authentication required)
	router.GET("/counter.js", collectorController.Counter)
	router.GET("/collect", collectorController.Collect)

	// Public website stats
	router.GET("/api/websites/public", websiteController.ListPublicWebsites)

	// Protected routes
	api := router.Group("/api")
	api.Use(middleware.AuthMiddleware())
	{
		// User routes
		api.GET("/auth/me", authController.Me)
		api.GET("/users/:id", userController.GetUser)
		api.PUT("/users/:id", userController.UpdateUser)
		api.POST("/users/:id/change-password", userController.ChangePassword)

		// Website routes
		api.POST("/websites", websiteController.CreateWebsite)
		api.GET("/websites", websiteController.ListWebsites)
		api.GET("/websites/:id", websiteController.GetWebsite)
		api.PUT("/websites/:id", websiteController.UpdateWebsite)
		api.DELETE("/websites/:id", websiteController.DeleteWebsite)
		api.GET("/websites/:id/tracking-code", websiteController.GetTrackingCode)
		api.GET("/websites/:id/stats", websiteController.GetWebsiteStats)
	}

	// Admin routes
	admin := router.Group("/api/admin")
	admin.Use(middleware.AuthMiddleware(), middleware.AdminMiddleware())
	{
		// System statistics
		admin.GET("/stats", userController.GetSystemStats)

		// User management
		admin.GET("/users", userController.ListUsers)
		admin.DELETE("/users/:id", userController.DeleteUser)

		// Group management
		admin.GET("/groups", userController.GetGroups)
		admin.GET("/groups/:id", userController.GetGroup)
		admin.POST("/groups", userController.CreateGroup)
		admin.PUT("/groups/:id", userController.UpdateGroup)
		admin.DELETE("/groups/:id", userController.DeleteGroup)
	}

	// Serve static files
	router.Static("/static", "./web/static")

	// Serve frontend
	router.NoRoute(func(c *gin.Context) {
		c.File("./web/index.html")
	})
}
