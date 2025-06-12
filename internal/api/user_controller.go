package api

import (
	"net/http"
	"strconv"
	"time"

	"aq3stat/internal/model"
	"aq3stat/internal/repository"
	"aq3stat/internal/service"
	"github.com/gin-gonic/gin"
)

// UserController handles user related API endpoints
type UserController struct {
	userService    *service.UserService
	websiteService *service.WebsiteService
	statService    *service.StatService
}

// NewUserController creates a new user controller
func NewUserController() *UserController {
	return &UserController{
		userService:    service.NewUserService(),
		websiteService: service.NewWebsiteService(),
		statService:    service.NewStatService(),
	}
}

// GetUser gets a user by ID
func (c *UserController) GetUser(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	user, err := c.userService.GetUserByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	ctx.JSON(http.StatusOK, user)
}

// UpdateUserRequest represents an update user request
type UpdateUserRequest struct {
	Email   string `json:"email" binding:"required,email"`
	Phone   string `json:"phone"`
	Address string `json:"address"`
	GroupID int    `json:"group_id"`
}

// UpdateUserProfileRequest represents an update user profile request
type UpdateUserProfileRequest struct {
	Email   string `json:"email" binding:"required,email"`
	Phone   string `json:"phone"`
	Address string `json:"address"`
}

// UpdateUserProfile updates user profile (for regular users)
func (c *UserController) UpdateUserProfile(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var req UpdateUserProfileRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := c.userService.GetUserByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	user.Email = req.Email
	user.Phone = req.Phone
	user.Address = req.Address

	err = c.userService.UpdateUserProfile(user)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Reload user with updated information
	updatedUser, err := c.userService.GetUserByID(id)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to reload user"})
		return
	}

	ctx.JSON(http.StatusOK, updatedUser)
}

// UpdateUser updates a user (for admin users)
func (c *UserController) UpdateUser(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var req UpdateUserRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := c.userService.GetUserByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	user.Email = req.Email
	user.Phone = req.Phone
	user.Address = req.Address
	if req.GroupID > 0 {
		user.GroupID = req.GroupID
	}

	err = c.userService.UpdateUserProfile(user)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Reload user with updated group information
	updatedUser, err := c.userService.GetUserByID(id)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to reload user"})
		return
	}

	ctx.JSON(http.StatusOK, updatedUser)
}

// DeleteUser deletes a user
func (c *UserController) DeleteUser(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	err = c.userService.DeleteUser(id)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete user"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "User deleted successfully"})
}

// ListUsers lists users with pagination
func (c *UserController) ListUsers(ctx *gin.Context) {
	pageStr := ctx.DefaultQuery("page", "1")
	pageSizeStr := ctx.DefaultQuery("page_size", "10")

	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}

	pageSize, err := strconv.Atoi(pageSizeStr)
	if err != nil || pageSize < 1 {
		pageSize = 10
	}

	users, total, err := c.userService.ListUsers(page, pageSize)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list users"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"users": users,
		"total": total,
		"page":  page,
		"size":  pageSize,
	})
}

// ChangePasswordRequest represents a change password request
type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required"`
}

// ChangePassword changes a user's password
func (c *UserController) ChangePassword(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var req ChangePasswordRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = c.userService.ChangePassword(id, req.OldPassword, req.NewPassword)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Password changed successfully"})
}

// ResetPasswordRequest represents a reset password request
type ResetPasswordRequest struct {
	NewPassword string `json:"new_password" binding:"required,min=6,max=20"`
}

// ResetPassword resets a user's password (admin only)
func (c *UserController) ResetPassword(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var req ResetPasswordRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = c.userService.ResetPassword(id, req.NewPassword)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Password reset successfully"})
}

// GetGroups gets all user groups
func (c *UserController) GetGroups(ctx *gin.Context) {
	groups, err := c.userService.GetGroups()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get groups"})
		return
	}

	ctx.JSON(http.StatusOK, groups)
}

// GetGroup gets a group by ID
func (c *UserController) GetGroup(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	group, err := c.userService.GetGroupByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Group not found"})
		return
	}

	ctx.JSON(http.StatusOK, group)
}

// CreateGroup creates a new group
func (c *UserController) CreateGroup(ctx *gin.Context) {
	var group model.Group
	if err := ctx.ShouldBindJSON(&group); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := c.userService.CreateGroup(&group)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create group"})
		return
	}

	ctx.JSON(http.StatusCreated, group)
}

// UpdateGroup updates a group
func (c *UserController) UpdateGroup(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	var group model.Group
	if err := ctx.ShouldBindJSON(&group); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	group.ID = id
	err = c.userService.UpdateGroup(&group)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update group"})
		return
	}

	ctx.JSON(http.StatusOK, group)
}

// DeleteGroup deletes a group
func (c *UserController) DeleteGroup(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	err = c.userService.DeleteGroup(id)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete group"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Group deleted successfully"})
}

// SystemStatsResponse represents system statistics response
type SystemStatsResponse struct {
	UserCount      int                         `json:"userCount"`
	WebsiteCount   int                         `json:"websiteCount"`
	TodayPV        int                         `json:"todayPV"`
	TodayIP        int                         `json:"todayIP"`
	TotalPV        int                         `json:"totalPV"`
	TotalIP        int                         `json:"totalIP"`
	RecentUsers    []model.User                `json:"recentUsers"`
	RecentWebsites []model.Website             `json:"recentWebsites"`
	TrendData      []repository.DailyStatsData `json:"trendData"`
}

// GetSystemStats gets system-wide statistics for admin dashboard
func (c *UserController) GetSystemStats(ctx *gin.Context) {
	var stats SystemStatsResponse

	// Get user count
	userCount, err := c.userService.GetUserCount()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user count"})
		return
	}
	stats.UserCount = userCount

	// Get website count
	websiteCount, err := c.websiteService.GetWebsiteCount()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get website count"})
		return
	}
	stats.WebsiteCount = websiteCount

	// Get today's stats
	today := time.Now().Format("2006-01-02")
	todayIP, todayPV, err := c.statService.GetSystemTodayStats(today)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get today's stats"})
		return
	}
	stats.TodayIP = todayIP
	stats.TodayPV = todayPV

	// Get total stats
	totalIP, totalPV, err := c.statService.GetSystemTotalStats()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get total stats"})
		return
	}
	stats.TotalIP = totalIP
	stats.TotalPV = totalPV

	// Get recent users (last 5)
	recentUsers, err := c.userService.GetRecentUsers(5)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get recent users"})
		return
	}
	stats.RecentUsers = recentUsers

	// Get recent websites (last 5)
	recentWebsites, err := c.websiteService.GetRecentWebsites(5)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get recent websites"})
		return
	}
	stats.RecentWebsites = recentWebsites

	// Get trend data for last 7 days
	trendData, err := c.statService.GetSystemTrendData(7)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get trend data"})
		return
	}
	stats.TrendData = trendData

	ctx.JSON(http.StatusOK, stats)
}
