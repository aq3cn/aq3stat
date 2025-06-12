package api

import (
	"net/http"
	"strconv"

	"aq3stat/internal/model"
	"aq3stat/internal/service"
	"github.com/gin-gonic/gin"
)

// WebsiteController handles website related API endpoints
type WebsiteController struct {
	websiteService *service.WebsiteService
	statService    *service.StatService
}

// NewWebsiteController creates a new website controller
func NewWebsiteController() *WebsiteController {
	return &WebsiteController{
		websiteService: service.NewWebsiteService(),
		statService:    service.NewStatService(),
	}
}

// CreateWebsiteRequest represents a create website request
type CreateWebsiteRequest struct {
	Name        string `json:"name" binding:"required"`
	URL         string `json:"url" binding:"required"`
	Description string `json:"description"`
	IsPublic    bool   `json:"is_public"`
}

// CreateWebsite creates a new website
func (c *WebsiteController) CreateWebsite(ctx *gin.Context) {
	var req CreateWebsiteRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get user ID from context (set by auth middleware)
	userID, exists := ctx.Get("userID")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	website := &model.Website{
		UserID:      userID.(int),
		Name:        req.Name,
		URL:         req.URL,
		Description: req.Description,
		IsPublic:    req.IsPublic,
	}

	err := c.websiteService.CreateWebsite(website)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, website)
}

// GetWebsite gets a website by ID
func (c *WebsiteController) GetWebsite(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid website ID"})
		return
	}

	website, err := c.websiteService.GetWebsiteByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Website not found"})
		return
	}

	// Check if user has permission to view this website
	userID, exists := ctx.Get("userID")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Check if user is the owner or if website is public
	if website.UserID != userID.(int) && !website.IsPublic {
		// Check if user has admin rights (from context)
		isAdmin, exists := ctx.Get("isAdmin")
		if !exists || !isAdmin.(bool) {
			ctx.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to view this website"})
			return
		}
	}

	ctx.JSON(http.StatusOK, website)
}

// UpdateWebsite updates a website
func (c *WebsiteController) UpdateWebsite(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid website ID"})
		return
	}

	var req CreateWebsiteRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	website, err := c.websiteService.GetWebsiteByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Website not found"})
		return
	}

	// Check if user has permission to update this website
	userID, exists := ctx.Get("userID")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Check if user is the owner
	if website.UserID != userID.(int) {
		// Check if user has admin rights (from context)
		isAdmin, exists := ctx.Get("isAdmin")
		if !exists || !isAdmin.(bool) {
			ctx.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to update this website"})
			return
		}
	}

	website.Name = req.Name
	website.URL = req.URL
	website.Description = req.Description
	website.IsPublic = req.IsPublic

	err = c.websiteService.UpdateWebsite(website)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, website)
}

// DeleteWebsite deletes a website
func (c *WebsiteController) DeleteWebsite(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid website ID"})
		return
	}

	website, err := c.websiteService.GetWebsiteByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Website not found"})
		return
	}

	// Check if user has permission to delete this website
	userID, exists := ctx.Get("userID")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Check if user is the owner
	if website.UserID != userID.(int) {
		// Check if user has admin rights (from context)
		isAdmin, exists := ctx.Get("isAdmin")
		if !exists || !isAdmin.(bool) {
			ctx.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to delete this website"})
			return
		}
	}

	err = c.websiteService.DeleteWebsite(id)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete website"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Website deleted successfully"})
}

// ListWebsites lists websites for the current user
func (c *WebsiteController) ListWebsites(ctx *gin.Context) {
	// Get user ID from context (set by auth middleware)
	userID, exists := ctx.Get("userID")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	websites, err := c.websiteService.ListWebsitesByUserID(userID.(int))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list websites"})
		return
	}

	ctx.JSON(http.StatusOK, websites)
}

// ListPublicWebsites lists public websites with pagination
func (c *WebsiteController) ListPublicWebsites(ctx *gin.Context) {
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

	websites, total, err := c.websiteService.ListPublicWebsites(page, pageSize)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list public websites"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"websites": websites,
		"total":    total,
		"page":     page,
		"size":     pageSize,
	})
}

// GetTrackingCode gets the tracking code for a website
func (c *WebsiteController) GetTrackingCode(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid website ID"})
		return
	}

	iconType := ctx.DefaultQuery("icon", "1")

	website, err := c.websiteService.GetWebsiteByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Website not found"})
		return
	}

	// Check if user has permission to get tracking code for this website
	userID, exists := ctx.Get("userID")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Check if user is the owner
	if website.UserID != userID.(int) {
		// Check if user has admin rights (from context)
		isAdmin, exists := ctx.Get("isAdmin")
		if !exists || !isAdmin.(bool) {
			ctx.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to get tracking code for this website"})
			return
		}
	}

	trackingCode := c.websiteService.GenerateTrackingCode(website, iconType)

	ctx.JSON(http.StatusOK, gin.H{"tracking_code": trackingCode})
}

// GetWebsiteStats gets stats for a website
func (c *WebsiteController) GetWebsiteStats(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid website ID"})
		return
	}

	website, err := c.websiteService.GetWebsiteByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Website not found"})
		return
	}

	// Check if user has permission to view stats for this website
	userID, exists := ctx.Get("userID")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Check if user is the owner or if website is public
	if website.UserID != userID.(int) && !website.IsPublic {
		// Check if user has admin rights (from context)
		isAdmin, exists := ctx.Get("isAdmin")
		if !exists || !isAdmin.(bool) {
			ctx.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to view stats for this website"})
			return
		}
	}

	// Update click-in time
	c.websiteService.UpdateClickInTime(id)

	// Get stats
	stats, err := c.statService.GetWebsiteStats(id)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get website stats"})
		return
	}

	ctx.JSON(http.StatusOK, stats)
}
