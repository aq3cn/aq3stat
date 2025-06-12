package model

import (
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// User represents a user in the system
type User struct {
	ID        int            `gorm:"primaryKey;type:int(11)" json:"id"`
	Username  string         `gorm:"size:50;not null;unique" json:"username"`
	Password  string         `gorm:"size:100;not null" json:"-"`
	Email     string         `gorm:"size:100;not null;unique" json:"email"`
	Phone     string         `gorm:"size:20" json:"phone"`
	Address   string         `gorm:"size:255" json:"address"`
	GroupID   int            `gorm:"not null;type:int(11)" json:"group_id"`
	Group     *Group         `json:"group,omitempty"`
	Websites  []Website      `json:"websites,omitempty"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// BeforeCreate is a GORM hook that sets timestamps and hashes password before creating
func (u *User) BeforeCreate(tx *gorm.DB) error {
	now := time.Now()
	if u.CreatedAt.IsZero() {
		u.CreatedAt = now
	}
	if u.UpdatedAt.IsZero() {
		u.UpdatedAt = now
	}
	return u.hashPassword()
}

// BeforeUpdate is a GORM hook that sets updated timestamp and hashes password before updating
func (u *User) BeforeUpdate(tx *gorm.DB) error {
	u.UpdatedAt = time.Now()
	return u.hashPassword()
}

// BeforeSave is a GORM hook that hashes the password before saving
func (u *User) BeforeSave(tx *gorm.DB) error {
	now := time.Now()
	if u.CreatedAt.IsZero() {
		u.CreatedAt = now
	}
	u.UpdatedAt = now
	return u.hashPassword()
}

// hashPassword hashes the password if it's not empty and not already hashed
func (u *User) hashPassword() error {
	if u.Password != "" && !u.isPasswordHashed() {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
		if err != nil {
			return err
		}
		u.Password = string(hashedPassword)
	}
	return nil
}

// isPasswordHashed checks if the password is already hashed (bcrypt hashes start with $2a$, $2b$, or $2y$)
func (u *User) isPasswordHashed() bool {
	return len(u.Password) >= 60 && (u.Password[:4] == "$2a$" || u.Password[:4] == "$2b$" || u.Password[:4] == "$2y$")
}

// CheckPassword checks if the provided password is correct
func (u *User) CheckPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	return err == nil
}

// Group represents a user group with specific permissions
type Group struct {
	ID             int            `gorm:"primaryKey;type:int(11)" json:"id"`
	Title          string         `gorm:"size:50;not null" json:"title"`
	IsAdmin        bool           `gorm:"default:false" json:"is_admin"`
	SiteAdmin      bool           `gorm:"default:false" json:"site_admin"`
	UserAdmin      bool           `gorm:"default:false" json:"user_admin"`
	RunTimeStat    bool           `gorm:"default:false" json:"run_time_stat"`
	ClientStat     bool           `gorm:"default:false" json:"client_stat"`
	AdminWebsite   bool           `gorm:"default:false" json:"admin_website"`
	HideIcon       bool           `gorm:"default:false" json:"hide_icon"`
	Users          []User         `json:"users,omitempty"`
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"-"`
}
