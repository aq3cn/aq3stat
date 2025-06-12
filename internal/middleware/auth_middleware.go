package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"aq3stat/internal/service"
)

// AuthMiddleware is a middleware for authentication
func AuthMiddleware() gin.HandlerFunc {
	authService := service.NewAuthService()

	return func(ctx *gin.Context) {
		// Get token from Authorization header
		authHeader := ctx.GetHeader("Authorization")
		if authHeader == "" {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
			ctx.Abort()
			return
		}

		// Check if the header has the Bearer prefix
		if !strings.HasPrefix(authHeader, "Bearer ") {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header must start with Bearer"})
			ctx.Abort()
			return
		}

		// Extract the token
		token := strings.TrimPrefix(authHeader, "Bearer ")

		// Validate token
		claims, err := authService.ValidateToken(token)
		if err != nil {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
			ctx.Abort()
			return
		}

		// Set user ID and username in context
		ctx.Set("userID", claims.UserID)
		ctx.Set("username", claims.Username)
		ctx.Set("groupID", claims.GroupID)

		ctx.Next()
	}
}

// AdminMiddleware is a middleware for admin authentication
func AdminMiddleware() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		// Get user from context (set by AuthMiddleware)
		_, exists := ctx.Get("userID")
		if !exists {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			ctx.Abort()
			return
		}

		// Get user's group
		groupID, exists := ctx.Get("groupID")
		if !exists {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User group not found"})
			ctx.Abort()
			return
		}

		// Check if user is an admin
		userService := service.NewUserService()
		group, err := userService.GetGroupByID(groupID.(int))
		if err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user group"})
			ctx.Abort()
			return
		}

		if !group.IsAdmin {
			ctx.JSON(http.StatusForbidden, gin.H{"error": "Admin access required"})
			ctx.Abort()
			return
		}

		// Set admin flag in context
		ctx.Set("isAdmin", true)

		ctx.Next()
	}
}

// PermissionMiddleware is a middleware for permission checking
func PermissionMiddleware(permission string) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		// Get user from context (set by AuthMiddleware)
		_, exists := ctx.Get("userID")
		if !exists {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			ctx.Abort()
			return
		}

		// Get user's group
		groupID, exists := ctx.Get("groupID")
		if !exists {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User group not found"})
			ctx.Abort()
			return
		}

		// Check if user has the required permission
		userService := service.NewUserService()
		group, err := userService.GetGroupByID(groupID.(int))
		if err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user group"})
			ctx.Abort()
			return
		}

		// Check permission based on the permission string
		hasPermission := false
		switch permission {
		case "admin":
			hasPermission = group.IsAdmin
		case "site_admin":
			hasPermission = group.SiteAdmin
		case "user_admin":
			hasPermission = group.UserAdmin
		case "run_time_stat":
			hasPermission = group.RunTimeStat
		case "client_stat":
			hasPermission = group.ClientStat
		case "admin_website":
			hasPermission = group.AdminWebsite
		}

		if !hasPermission {
			ctx.JSON(http.StatusForbidden, gin.H{"error": "Permission denied"})
			ctx.Abort()
			return
		}

		ctx.Next()
	}
}

// CORSMiddleware is a middleware for CORS
func CORSMiddleware() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		ctx.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		ctx.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		ctx.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		ctx.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if ctx.Request.Method == "OPTIONS" {
			ctx.AbortWithStatus(204)
			return
		}

		ctx.Next()
	}
}
