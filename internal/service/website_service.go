package service

import (
	"errors"
	"strings"

	"aq3stat/internal/model"
	"aq3stat/internal/repository"
)

// WebsiteService handles website related business logic
type WebsiteService struct {
	websiteRepo *repository.WebsiteRepository
}

// NewWebsiteService creates a new website service
func NewWebsiteService() *WebsiteService {
	return &WebsiteService{
		websiteRepo: repository.NewWebsiteRepository(),
	}
}

// CreateWebsite creates a new website
func (s *WebsiteService) CreateWebsite(website *model.Website) error {
	// Validate website URL
	if !strings.HasPrefix(website.URL, "http://") && !strings.HasPrefix(website.URL, "https://") {
		return errors.New("website URL must start with http:// or https://")
	}

	// Validate website name length
	if len(website.Name) > 50 {
		return errors.New("website name must be less than 50 characters")
	}

	// Validate website description length
	if len(website.Description) > 255 {
		return errors.New("website description must be less than 255 characters")
	}

	return s.websiteRepo.Create(website)
}

// GetWebsiteByID gets a website by ID
func (s *WebsiteService) GetWebsiteByID(id int) (*model.Website, error) {
	return s.websiteRepo.FindByID(id)
}

// UpdateWebsite updates a website
func (s *WebsiteService) UpdateWebsite(website *model.Website) error {
	// Validate website URL
	if !strings.HasPrefix(website.URL, "http://") && !strings.HasPrefix(website.URL, "https://") {
		return errors.New("website URL must start with http:// or https://")
	}

	// Validate website name length
	if len(website.Name) > 50 {
		return errors.New("website name must be less than 50 characters")
	}

	// Validate website description length
	if len(website.Description) > 255 {
		return errors.New("website description must be less than 255 characters")
	}

	return s.websiteRepo.Update(website)
}

// DeleteWebsite deletes a website
func (s *WebsiteService) DeleteWebsite(id int) error {
	return s.websiteRepo.Delete(id)
}

// ListWebsitesByUserID lists websites for a user
func (s *WebsiteService) ListWebsitesByUserID(userID int) ([]model.Website, error) {
	return s.websiteRepo.ListByUserID(userID)
}

// ListPublicWebsites lists public websites with pagination
func (s *WebsiteService) ListPublicWebsites(page, pageSize int) ([]model.Website, int64, error) {
	return s.websiteRepo.ListPublic(page, pageSize)
}

// UpdateClickInTime updates the last click-in time for a website
func (s *WebsiteService) UpdateClickInTime(id int) error {
	return s.websiteRepo.UpdateClickInTime(id)
}

// GenerateTrackingCode generates the JavaScript tracking code for a website
func (s *WebsiteService) GenerateTrackingCode(website *model.Website, iconType string) string {
	baseURL := "http://localhost:8080" // Replace with actual base URL from config

	var code strings.Builder

	code.WriteString("<script type=\"text/javascript\">\n")
	code.WriteString("// aq3stat Tracking Code\n")
	code.WriteString("(function() {\n")
	code.WriteString("  var hs = document.createElement('script');\n")
	code.WriteString("  hs.type = 'text/javascript';\n")
	code.WriteString("  hs.async = true;\n")

	// Generate URL for the counter script
	counterURL := baseURL + "/counter.js?id=" + string(website.ID)
	if iconType != "" {
		counterURL += "&icon=" + iconType
	}

	code.WriteString("  hs.src = '" + counterURL + "';\n")
	code.WriteString("  var s = document.getElementsByTagName('script')[0];\n")
	code.WriteString("  s.parentNode.insertBefore(hs, s);\n")
	code.WriteString("})();\n")
	code.WriteString("</script>\n")

	return code.String()
}

// GetWebsiteCount gets total website count
func (s *WebsiteService) GetWebsiteCount() (int, error) {
	return s.websiteRepo.GetCount()
}

// GetRecentWebsites gets recent websites
func (s *WebsiteService) GetRecentWebsites(limit int) ([]model.Website, error) {
	return s.websiteRepo.GetRecent(limit)
}
