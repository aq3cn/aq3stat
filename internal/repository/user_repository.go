package repository

import (
	"errors"

	"aq3stat/internal/model"
	"aq3stat/pkg/database"
	"gorm.io/gorm"
)

// UserRepository handles database operations for users
type UserRepository struct {
	db *gorm.DB
}

// NewUserRepository creates a new user repository
func NewUserRepository() *UserRepository {
	return &UserRepository{
		db: database.DB,
	}
}

// Create creates a new user
func (r *UserRepository) Create(user *model.User) error {
	return r.db.Create(user).Error
}

// FindByID finds a user by ID
func (r *UserRepository) FindByID(id int) (*model.User, error) {
	var user model.User
	err := r.db.Preload("Group").First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// FindByUsername finds a user by username
func (r *UserRepository) FindByUsername(username string) (*model.User, error) {
	var user model.User
	err := r.db.Preload("Group").Where("username = ?", username).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// FindByEmail finds a user by email
func (r *UserRepository) FindByEmail(email string) (*model.User, error) {
	var user model.User
	err := r.db.Preload("Group").Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// Update updates a user
func (r *UserRepository) Update(user *model.User) error {
	return r.db.Save(user).Error
}

// Delete deletes a user
func (r *UserRepository) Delete(id int) error {
	return r.db.Delete(&model.User{}, id).Error
}

// List returns a list of users with pagination
func (r *UserRepository) List(page, pageSize int) ([]model.User, int64, error) {
	var users []model.User
	var total int64

	r.db.Model(&model.User{}).Count(&total)

	offset := (page - 1) * pageSize
	err := r.db.Preload("Group").Offset(offset).Limit(pageSize).Find(&users).Error
	if err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

// ChangePassword changes a user's password
func (r *UserRepository) ChangePassword(id int, oldPassword, newPassword string) error {
	user, err := r.FindByID(id)
	if err != nil {
		return err
	}

	if !user.CheckPassword(oldPassword) {
		return errors.New("incorrect old password")
	}

	user.Password = newPassword
	return r.Update(user)
}

// GetCount gets total user count
func (r *UserRepository) GetCount() (int, error) {
	var count int64
	err := r.db.Model(&model.User{}).Count(&count).Error
	return int(count), err
}

// GetRecent gets recent users
func (r *UserRepository) GetRecent(limit int) ([]model.User, error) {
	var users []model.User
	err := r.db.Preload("Group").Order("created_at DESC").Limit(limit).Find(&users).Error
	if err != nil {
		return nil, err
	}
	return users, nil
}

// GroupRepository handles database operations for user groups
type GroupRepository struct {
	db *gorm.DB
}

// NewGroupRepository creates a new group repository
func NewGroupRepository() *GroupRepository {
	return &GroupRepository{
		db: database.DB,
	}
}

// Create creates a new group
func (r *GroupRepository) Create(group *model.Group) error {
	return r.db.Create(group).Error
}

// FindByID finds a group by ID
func (r *GroupRepository) FindByID(id int) (*model.Group, error) {
	var group model.Group
	err := r.db.First(&group, id).Error
	if err != nil {
		return nil, err
	}
	return &group, nil
}

// Update updates a group
func (r *GroupRepository) Update(group *model.Group) error {
	return r.db.Save(group).Error
}

// Delete deletes a group
func (r *GroupRepository) Delete(id int) error {
	return r.db.Delete(&model.Group{}, id).Error
}

// List returns a list of all groups
func (r *GroupRepository) List() ([]model.Group, error) {
	var groups []model.Group
	err := r.db.Find(&groups).Error
	if err != nil {
		return nil, err
	}
	return groups, nil
}
