package migrations

import (
	"log"

	"aq3stat/internal/model"
	"aq3stat/pkg/database"
)

// Migrate runs all database migrations
func Migrate() {
	// Auto migrate all models
	err := database.DB.AutoMigrate(
		&model.Group{},     // Migrate groups first
		&model.User{},      // Then users
		&model.Website{},
		&model.Stat{},
		&model.IPData{},
		&model.Email{},
		&model.EmailConfig{},
		&model.SearchEngine{},
	)

	if err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}

	// Add foreign key constraints manually
	addForeignKeyConstraints()

	log.Println("Database migration completed")

	// Seed initial data
	SeedData()
}

// addForeignKeyConstraints adds foreign key constraints manually
func addForeignKeyConstraints() {
	// Add foreign key constraint for users.group_id -> groups.id
	err := database.DB.Exec("ALTER TABLE users ADD CONSTRAINT fk_users_group FOREIGN KEY (group_id) REFERENCES groups(id)").Error
	if err != nil {
		log.Printf("Warning: Failed to add foreign key constraint for users.group_id: %v", err)
	}

	// Add foreign key constraint for websites.user_id -> users.id
	err = database.DB.Exec("ALTER TABLE websites ADD CONSTRAINT fk_websites_user FOREIGN KEY (user_id) REFERENCES users(id)").Error
	if err != nil {
		log.Printf("Warning: Failed to add foreign key constraint for websites.user_id: %v", err)
	}

	// Add foreign key constraint for stats.website_id -> websites.id
	err = database.DB.Exec("ALTER TABLE stats ADD CONSTRAINT fk_stats_website FOREIGN KEY (website_id) REFERENCES websites(id)").Error
	if err != nil {
		log.Printf("Warning: Failed to add foreign key constraint for stats.website_id: %v", err)
	}

	// Add foreign key constraint for emails.user_id -> users.id
	err = database.DB.Exec("ALTER TABLE emails ADD CONSTRAINT fk_emails_user FOREIGN KEY (user_id) REFERENCES users(id)").Error
	if err != nil {
		log.Printf("Warning: Failed to add foreign key constraint for emails.user_id: %v", err)
	}

	log.Println("Foreign key constraints added")
}

// SeedData seeds initial data into the database
func SeedData() {
	// Seed default user groups
	SeedGroups()

	// Seed default admin user
	SeedAdminUser()

	// Seed search engines
	SeedSearchEngines()

	// Seed email templates
	SeedEmailTemplates()

	log.Println("Data seeding completed")
}

// SeedGroups seeds default user groups
func SeedGroups() {
	groups := []model.Group{
		{
			Title:          "Administrator",
			IsAdmin:        true,
			SiteAdmin:      true,
			UserAdmin:      true,
			RunTimeStat:    true,
			ClientStat:     true,
			AdminWebsite:   true,
			HideIcon:       false,
		},
		{
			Title:          "Regular User",
			IsAdmin:        false,
			SiteAdmin:      true,
			UserAdmin:      false,
			RunTimeStat:    true,
			ClientStat:     true,
			AdminWebsite:   false,
			HideIcon:       false,
		},
		{
			Title:          "Premium User",
			IsAdmin:        false,
			SiteAdmin:      true,
			UserAdmin:      false,
			RunTimeStat:    true,
			ClientStat:     true,
			AdminWebsite:   false,
			HideIcon:       true,
		},
	}

	for _, group := range groups {
		var count int64
		database.DB.Model(&model.Group{}).Where("title = ?", group.Title).Count(&count)
		if count == 0 {
			database.DB.Create(&group)
		}
	}
}

// SeedAdminUser seeds the default admin user
func SeedAdminUser() {
	var adminGroup model.Group
	database.DB.Where("title = ?", "Administrator").First(&adminGroup)

	var count int64
	database.DB.Model(&model.User{}).Where("username = ?", "admin").Count(&count)
	if count == 0 {
		admin := model.User{
			Username: "admin",
			Password: "admin123", // Will be hashed by the BeforeSave hook
			Email:    "admin@aq3stat.com",
			GroupID:  adminGroup.ID,
		}
		database.DB.Create(&admin)
	}
}

// SeedSearchEngines seeds default search engines
func SeedSearchEngines() {
	searchEngines := []model.SearchEngine{
		{
			Name:         "Baidu",
			Domains:      "baidu.com",
			QueryParams:  "wd,word",
			DisplayOrder: 1,
		},
		{
			Name:         "Google",
			Domains:      "google.cn,google.com",
			QueryParams:  "q",
			DisplayOrder: 2,
		},
		{
			Name:         "Yahoo",
			Domains:      "yahoo.com",
			QueryParams:  "p",
			DisplayOrder: 3,
		},
		{
			Name:         "Bing",
			Domains:      "bing.com",
			QueryParams:  "q",
			DisplayOrder: 4,
		},
		{
			Name:         "Sogou",
			Domains:      "sogou.com",
			QueryParams:  "query",
			DisplayOrder: 5,
		},
	}

	for _, se := range searchEngines {
		var count int64
		database.DB.Model(&model.SearchEngine{}).Where("name = ?", se.Name).Count(&count)
		if count == 0 {
			database.DB.Create(&se)
		}
	}
}

// SeedEmailTemplates seeds default email templates
func SeedEmailTemplates() {
	emailTemplates := []model.EmailConfig{
		{
			Type:        "REGISTER",
			IsEnabled:   true,
			MailSubject: "Welcome to aq3stat - Registration Confirmation",
			MailBody:    "Dear {{username}},\n\nThank you for registering with aq3stat. Your account has been created successfully.\n\nUsername: {{username}}\n\nPlease visit our website to start tracking your websites.\n\nBest regards,\nThe aq3stat Team",
			MailType:    "TEXT",
		},
		{
			Type:        "RESET_PASSWORD",
			IsEnabled:   true,
			MailSubject: "aq3stat - Password Reset",
			MailBody:    "Dear {{username}},\n\nYou have requested to reset your password. Please use the following link to reset your password:\n\n{{reset_link}}\n\nIf you did not request this, please ignore this email.\n\nBest regards,\nThe aq3stat Team",
			MailType:    "TEXT",
		},
	}

	for _, template := range emailTemplates {
		var count int64
		database.DB.Model(&model.EmailConfig{}).Where("type = ?", template.Type).Count(&count)
		if count == 0 {
			database.DB.Create(&template)
		}
	}
}
