package model

import (
	"time"

	"gorm.io/gorm"
)

// Website represents a website being tracked
type Website struct {
	ID          int            `gorm:"primaryKey;type:int" json:"id"`
	UserID      int            `gorm:"not null;type:int" json:"user_id"`
	User        *User          `json:"user,omitempty"`
	Name        string         `gorm:"size:100;not null" json:"name"`
	URL         string         `gorm:"size:255;not null" json:"url"`
	Description string         `gorm:"size:255" json:"description"`
	IsPublic    bool           `gorm:"default:false" json:"is_public"`
	StartTime   time.Time      `json:"start_time"`
	ClickInTime *time.Time     `json:"click_in_time"`
	Stats       []Stat         `json:"stats,omitempty"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

// Stat represents a single visit statistic record
type Stat struct {
	ID            int            `gorm:"primaryKey;type:int" json:"id"`
	WebsiteID     int            `gorm:"not null;index;type:int" json:"website_id"`
	Website       *Website       `json:"website,omitempty"`
	Time          time.Time      `gorm:"index" json:"time"`
	LeaveTime     time.Time      `json:"leave_time"`
	IP            string         `gorm:"size:50;not null;index" json:"ip"`
	Count         int            `gorm:"default:1" json:"count"`
	Referer       string         `gorm:"size:255" json:"referer"`
	BaseReferer   string         `gorm:"size:255" json:"base_referer"`
	SearchEngine  string         `gorm:"size:50" json:"search_engine"`
	Keyword       string         `gorm:"size:255" json:"keyword"`
	Location      string         `gorm:"size:255" json:"location"`
	ScreenColor   int            `json:"screen_color"`
	ScreenSize    string         `gorm:"size:20" json:"screen_size"`
	Browser       string         `gorm:"size:50" json:"browser"`
	OS            string         `gorm:"size:50" json:"os"`
	OSLang        string         `gorm:"size:20" json:"os_lang"`
	HasAlexaBar   bool           `gorm:"default:false" json:"has_alexa_bar"`
	Address       string         `gorm:"size:255" json:"address"`
	Province      string         `gorm:"size:50" json:"province"`
	ISP           string         `gorm:"size:50" json:"isp"`
	ReVisitTimes  int            `gorm:"default:1" json:"re_visit_times"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"-"`
}

// IPData represents IP address location data
type IPData struct {
	ID        int            `gorm:"primaryKey;type:int" json:"id"`
	StartIP   uint           `gorm:"not null;index" json:"start_ip"`
	EndIP     uint           `gorm:"not null;index" json:"end_ip"`
	Address1  string         `gorm:"size:255" json:"address1"` // Province/City
	Address2  string         `gorm:"size:255" json:"address2"` // ISP
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}
