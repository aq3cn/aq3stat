package repository

import (
	"time"

	"aq3stat/internal/model"
	"aq3stat/pkg/database"
	"gorm.io/gorm"
)

// EmailRepository handles database operations for emails
type EmailRepository struct {
	db *gorm.DB
}

// NewEmailRepository creates a new email repository
func NewEmailRepository() *EmailRepository {
	return &EmailRepository{
		db: database.DB,
	}
}

// Create creates a new email record
func (r *EmailRepository) Create(email *model.Email) error {
	email.SentTime = time.Now()
	return r.db.Create(email).Error
}

// FindByID finds an email by ID
func (r *EmailRepository) FindByID(id int) (*model.Email, error) {
	var email model.Email
	err := r.db.Preload("User").First(&email, id).Error
	if err != nil {
		return nil, err
	}
	return &email, nil
}

// Delete deletes an email
func (r *EmailRepository) Delete(id int) error {
	return r.db.Delete(&model.Email{}, id).Error
}

// List returns a list of emails with pagination
func (r *EmailRepository) List(page, pageSize int) ([]model.Email, int64, error) {
	var emails []model.Email
	var total int64

	r.db.Model(&model.Email{}).Count(&total)

	offset := (page - 1) * pageSize
	err := r.db.Preload("User").Order("sent_time DESC").Offset(offset).Limit(pageSize).Find(&emails).Error
	if err != nil {
		return nil, 0, err
	}

	return emails, total, nil
}

// EmailConfigRepository handles database operations for email configurations
type EmailConfigRepository struct {
	db *gorm.DB
}

// NewEmailConfigRepository creates a new email config repository
func NewEmailConfigRepository() *EmailConfigRepository {
	return &EmailConfigRepository{
		db: database.DB,
	}
}

// FindByType finds an email config by type
func (r *EmailConfigRepository) FindByType(configType string) (*model.EmailConfig, error) {
	var config model.EmailConfig
	err := r.db.Where("type = ?", configType).First(&config).Error
	if err != nil {
		return nil, err
	}
	return &config, nil
}

// Update updates an email config
func (r *EmailConfigRepository) Update(config *model.EmailConfig) error {
	return r.db.Save(config).Error
}

// List returns a list of all email configs
func (r *EmailConfigRepository) List() ([]model.EmailConfig, error) {
	var configs []model.EmailConfig
	err := r.db.Find(&configs).Error
	if err != nil {
		return nil, err
	}
	return configs, nil
}
