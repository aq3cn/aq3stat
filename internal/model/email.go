/*
 * @Author: xxx@xxx.com
 * @Date: 2025-05-22 19:00:56
 * @LastEditors: xxx@xxx.com
 * @LastEditTime: 2025-05-22 19:08:18
 * @FilePath: \cnzz1\internal\model\email.go
 * @Description:
 *
 * Copyright (c) 2022 by xxx@xxx.com, All Rights Reserved.
 */
package model

import (
	"time"

	"gorm.io/gorm"
)

// Email represents an email sent by the system
type Email struct {
	ID          int            `gorm:"primaryKey;type:int" json:"id"`
	UserID      int            `gorm:"type:int" json:"user_id"`
	User        *User          `json:"user,omitempty"`
	Receivers   string         `gorm:"size:1000" json:"receivers"`
	MailSubject string         `gorm:"size:255" json:"mail_subject"`
	MailBody    string         `gorm:"type:text" json:"mail_body"`
	MailType    string         `gorm:"size:10" json:"mail_type"` // TEXT or HTML
	SentTime    time.Time      `json:"sent_time"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

// EmailConfig represents email configuration for registration and password reset
type EmailConfig struct {
	ID          int            `gorm:"primaryKey;type:int" json:"id"`
	Type        string         `gorm:"size:20;not null" json:"type"` // REGISTER or RESET_PASSWORD
	IsEnabled   bool           `gorm:"default:true" json:"is_enabled"`
	MailSubject string         `gorm:"size:255" json:"mail_subject"`
	MailBody    string         `gorm:"type:text" json:"mail_body"`
	MailType    string         `gorm:"size:10" json:"mail_type"` // TEXT or HTML
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}
