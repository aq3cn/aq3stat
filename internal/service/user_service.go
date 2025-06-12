package service

import (
	"errors"

	"aq3stat/internal/model"
	"aq3stat/internal/repository"
)

// UserService handles user related business logic
type UserService struct {
	userRepo  *repository.UserRepository
	groupRepo *repository.GroupRepository
}

// NewUserService creates a new user service
func NewUserService() *UserService {
	return &UserService{
		userRepo:  repository.NewUserRepository(),
		groupRepo: repository.NewGroupRepository(),
	}
}

// GetUserByID gets a user by ID
func (s *UserService) GetUserByID(id int) (*model.User, error) {
	return s.userRepo.FindByID(id)
}

// UpdateUser updates a user (including password)
func (s *UserService) UpdateUser(user *model.User) error {
	// Check if email already exists for another user
	existingUser, err := s.userRepo.FindByEmail(user.Email)
	if err == nil && existingUser != nil && existingUser.ID != user.ID {
		return errors.New("email already exists")
	}

	return s.userRepo.Update(user)
}

// UpdateUserProfile updates user profile information (excluding password)
func (s *UserService) UpdateUserProfile(user *model.User) error {
	// Check if email already exists for another user
	existingUser, err := s.userRepo.FindByEmail(user.Email)
	if err == nil && existingUser != nil && existingUser.ID != user.ID {
		return errors.New("email already exists")
	}

	return s.userRepo.UpdateProfile(user)
}

// DeleteUser deletes a user
func (s *UserService) DeleteUser(id int) error {
	return s.userRepo.Delete(id)
}

// ListUsers lists users with pagination
func (s *UserService) ListUsers(page, pageSize int) ([]model.User, int64, error) {
	return s.userRepo.List(page, pageSize)
}

// ChangePassword changes a user's password
func (s *UserService) ChangePassword(id int, oldPassword, newPassword string) error {
	return s.userRepo.ChangePassword(id, oldPassword, newPassword)
}

// ResetPassword resets a user's password (admin only, no old password required)
func (s *UserService) ResetPassword(id int, newPassword string) error {
	return s.userRepo.ResetPassword(id, newPassword)
}

// GetGroups gets all user groups
func (s *UserService) GetGroups() ([]model.Group, error) {
	return s.groupRepo.List()
}

// GetGroupByID gets a group by ID
func (s *UserService) GetGroupByID(id int) (*model.Group, error) {
	return s.groupRepo.FindByID(id)
}

// CreateGroup creates a new group
func (s *UserService) CreateGroup(group *model.Group) error {
	return s.groupRepo.Create(group)
}

// UpdateGroup updates a group
func (s *UserService) UpdateGroup(group *model.Group) error {
	return s.groupRepo.Update(group)
}

// DeleteGroup deletes a group
func (s *UserService) DeleteGroup(id int) error {
	return s.groupRepo.Delete(id)
}

// GetUserCount gets total user count
func (s *UserService) GetUserCount() (int, error) {
	return s.userRepo.GetCount()
}

// GetRecentUsers gets recent users
func (s *UserService) GetRecentUsers(limit int) ([]model.User, error) {
	return s.userRepo.GetRecent(limit)
}
