package service

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"aq3stat/internal/model"
	"aq3stat/internal/repository"
)

// AuthService handles authentication related business logic
type AuthService struct {
	userRepo *repository.UserRepository
}

// NewAuthService creates a new auth service
func NewAuthService() *AuthService {
	return &AuthService{
		userRepo: repository.NewUserRepository(),
	}
}

// Claims represents JWT claims
type Claims struct {
	UserID   int    `json:"user_id"`
	Username string `json:"username"`
	GroupID  int    `json:"group_id"`
	jwt.RegisteredClaims
}

// Login authenticates a user and returns a JWT token
func (s *AuthService) Login(username, password string) (string, error) {
	user, err := s.userRepo.FindByUsername(username)
	if err != nil {
		return "", errors.New("invalid username or password")
	}

	if !user.CheckPassword(password) {
		return "", errors.New("invalid username or password")
	}

	// Create JWT token
	expirationTime, _ := time.ParseDuration(os.Getenv("JWT_EXPIRATION"))
	claims := &Claims{
		UserID:   user.ID,
		Username: user.Username,
		GroupID:  user.GroupID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(expirationTime)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "aq3stat",
			Subject:   user.Username,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// Register registers a new user
func (s *AuthService) Register(user *model.User) error {
	// Check if username already exists
	existingUser, err := s.userRepo.FindByUsername(user.Username)
	if err == nil && existingUser != nil {
		return errors.New("username already exists")
	}

	// Check if email already exists
	existingUser, err = s.userRepo.FindByEmail(user.Email)
	if err == nil && existingUser != nil {
		return errors.New("email already exists")
	}

	// Set default group for new users
	groupRepo := repository.NewGroupRepository()
	groups, err := groupRepo.List()
	if err != nil {
		return err
	}

	// Find the "Regular User" group
	for _, group := range groups {
		if group.Title == "Regular User" {
			user.GroupID = group.ID
			break
		}
	}

	// Create the user
	return s.userRepo.Create(user)
}

// ValidateToken validates a JWT token and returns the claims
func (s *AuthService) ValidateToken(tokenString string) (*Claims, error) {
	claims := &Claims{}

	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(os.Getenv("JWT_SECRET")), nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}

// GetUserFromToken gets a user from a JWT token
func (s *AuthService) GetUserFromToken(tokenString string) (*model.User, error) {
	claims, err := s.ValidateToken(tokenString)
	if err != nil {
		return nil, err
	}

	user, err := s.userRepo.FindByID(claims.UserID)
	if err != nil {
		return nil, err
	}

	return user, nil
}
