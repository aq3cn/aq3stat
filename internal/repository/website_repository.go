package repository

import (
	"time"

	"aq3stat/internal/model"
	"aq3stat/pkg/database"
	"gorm.io/gorm"
)

// WebsiteRepository handles database operations for websites
type WebsiteRepository struct {
	db *gorm.DB
}

// NewWebsiteRepository creates a new website repository
func NewWebsiteRepository() *WebsiteRepository {
	return &WebsiteRepository{
		db: database.DB,
	}
}

// Create creates a new website
func (r *WebsiteRepository) Create(website *model.Website) error {
	website.StartTime = time.Now()
	return r.db.Create(website).Error
}

// FindByID finds a website by ID
func (r *WebsiteRepository) FindByID(id int) (*model.Website, error) {
	var website model.Website
	err := r.db.Preload("User").First(&website, id).Error
	if err != nil {
		return nil, err
	}
	return &website, nil
}

// Update updates a website
func (r *WebsiteRepository) Update(website *model.Website) error {
	return r.db.Save(website).Error
}

// Delete deletes a website
func (r *WebsiteRepository) Delete(id int) error {
	// First delete all stats for this website
	err := r.db.Where("website_id = ?", id).Delete(&model.Stat{}).Error
	if err != nil {
		return err
	}

	// Then delete the website
	return r.db.Delete(&model.Website{}, id).Error
}

// ListByUserID returns a list of websites for a user
func (r *WebsiteRepository) ListByUserID(userID int) ([]model.Website, error) {
	var websites []model.Website
	err := r.db.Where("user_id = ?", userID).Find(&websites).Error
	if err != nil {
		return nil, err
	}
	return websites, nil
}

// ListPublic returns a list of public websites
func (r *WebsiteRepository) ListPublic(page, pageSize int) ([]model.Website, int64, error) {
	var websites []model.Website
	var total int64

	r.db.Model(&model.Website{}).Where("is_public = ?", true).Count(&total)

	offset := (page - 1) * pageSize
	err := r.db.Preload("User").Where("is_public = ?", true).Offset(offset).Limit(pageSize).Find(&websites).Error
	if err != nil {
		return nil, 0, err
	}

	return websites, total, nil
}

// UpdateClickInTime updates the last click-in time for a website
func (r *WebsiteRepository) UpdateClickInTime(id int) error {
	now := time.Now()
	return r.db.Model(&model.Website{}).Where("id = ?", id).Update("click_in_time", &now).Error
}

// GetCount gets total website count
func (r *WebsiteRepository) GetCount() (int, error) {
	var count int64
	err := r.db.Model(&model.Website{}).Count(&count).Error
	return int(count), err
}

// GetRecent gets recent websites
func (r *WebsiteRepository) GetRecent(limit int) ([]model.Website, error) {
	var websites []model.Website
	err := r.db.Preload("User").Order("created_at DESC").Limit(limit).Find(&websites).Error
	if err != nil {
		return nil, err
	}
	return websites, nil
}

// StatRepository handles database operations for stats
type StatRepository struct {
	db *gorm.DB
}

// NewStatRepository creates a new stat repository
func NewStatRepository() *StatRepository {
	return &StatRepository{
		db: database.DB,
	}
}

// Create creates a new stat record
func (r *StatRepository) Create(stat *model.Stat) error {
	return r.db.Create(stat).Error
}

// FindByID finds a stat by ID
func (r *StatRepository) FindByID(id int) (*model.Stat, error) {
	var stat model.Stat
	err := r.db.First(&stat, id).Error
	if err != nil {
		return nil, err
	}
	return &stat, nil
}

// Update updates a stat
func (r *StatRepository) Update(stat *model.Stat) error {
	return r.db.Save(stat).Error
}

// FindByWebsiteIDAndIP finds a stat by website ID and IP for today
func (r *StatRepository) FindByWebsiteIDAndIP(websiteID int, ip string, today time.Time) (*model.Stat, error) {
	var stat model.Stat
	err := r.db.Where("website_id = ? AND ip = ? AND time >= ?", websiteID, ip, today).First(&stat).Error
	if err != nil {
		return nil, err
	}
	return &stat, nil
}

// FindByWebsiteIDAndIPYesterday finds a stat by website ID and IP for yesterday
func (r *StatRepository) FindByWebsiteIDAndIPYesterday(websiteID int, ip string, yesterday, today time.Time) (*model.Stat, error) {
	var stat model.Stat
	err := r.db.Where("website_id = ? AND ip = ? AND time >= ? AND time < ?", websiteID, ip, yesterday, today).First(&stat).Error
	if err != nil {
		return nil, err
	}
	return &stat, nil
}

// IPDataRepository handles database operations for IP data
type IPDataRepository struct {
	db *gorm.DB
}

// NewIPDataRepository creates a new IP data repository
func NewIPDataRepository() *IPDataRepository {
	return &IPDataRepository{
		db: database.DB,
	}
}

// FindByIP finds IP data by IP address
func (r *IPDataRepository) FindByIP(ip uint) (*model.IPData, error) {
	var ipData model.IPData
	err := r.db.Where("start_ip <= ? AND end_ip >= ?", ip, ip).First(&ipData).Error
	if err != nil {
		return nil, err
	}
	return &ipData, nil
}
