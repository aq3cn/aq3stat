package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"aq3stat/internal/model"
	"aq3stat/internal/service"
)

// AuthController handles authentication related API endpoints
type AuthController struct {
	authService *service.AuthService
}

// NewAuthController creates a new auth controller
func NewAuthController() *AuthController {
	return &AuthController{
		authService: service.NewAuthService(),
	}
}

// LoginRequest represents a login request
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse represents a login response
type LoginResponse struct {
	Token string      `json:"token"`
	User  *model.User `json:"user"`
}

// Login handles user login
func (c *AuthController) Login(ctx *gin.Context) {
	var req LoginRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	token, err := c.authService.Login(req.Username, req.Password)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	// Get user from token
	user, err := c.authService.GetUserFromToken(token)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user information"})
		return
	}

	ctx.JSON(http.StatusOK, LoginResponse{
		Token: token,
		User:  user,
	})
}

// RegisterRequest represents a register request
type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Phone    string `json:"phone"`
	Address  string `json:"address"`
}

// Register handles user registration
func (c *AuthController) Register(ctx *gin.Context) {
	var req RegisterRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user := &model.User{
		Username: req.Username,
		Password: req.Password,
		Email:    req.Email,
		Phone:    req.Phone,
		Address:  req.Address,
	}

	err := c.authService.Register(user)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "User registered successfully"})
}

// Me gets the current user
func (c *AuthController) Me(ctx *gin.Context) {
	// Get token from Authorization header
	token := ctx.GetHeader("Authorization")
	if token == "" {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
		return
	}

	// Remove "Bearer " prefix if present
	if len(token) > 7 && token[:7] == "Bearer " {
		token = token[7:]
	}

	// Get user from token
	user, err := c.authService.GetUserFromToken(token)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, user)
}

// GeneratePassword generates a bcrypt hash for a password (temporary endpoint for debugging)
func (c *AuthController) GeneratePassword(ctx *gin.Context) {
	password := ctx.Param("password")
	if password == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Password parameter is required"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Test verification
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	verificationResult := "SUCCESS"
	if err != nil {
		verificationResult = "FAILED: " + err.Error()
	}

	ctx.JSON(http.StatusOK, gin.H{
		"password": password,
		"hash": string(hashedPassword),
		"verification": verificationResult,
	})
}
