package service

import (
	"time"

	"aq3stat/internal/repository"
)

// StatService handles statistics related business logic
type StatService struct {
	websiteRepo       *repository.WebsiteRepository
	statAnalyticsRepo *repository.StatAnalyticsRepository
}

// NewStatService creates a new stat service
func NewStatService() *StatService {
	return &StatService{
		websiteRepo:       repository.NewWebsiteRepository(),
		statAnalyticsRepo: repository.NewStatAnalyticsRepository(),
	}
}

// GetWebsiteStats gets comprehensive stats for a website
type WebsiteStats struct {
	// Today stats
	TodayIPCount int64 `json:"today_ip_count"`
	TodayPVCount int64 `json:"today_pv_count"`

	// Yesterday stats
	YesterdayIPCount int64 `json:"yesterday_ip_count"`
	YesterdayPVCount int64 `json:"yesterday_pv_count"`

	// This week stats
	ThisWeekIPCount int64 `json:"this_week_ip_count"`
	ThisWeekPVCount int64 `json:"this_week_pv_count"`

	// Last week stats
	LastWeekIPCount int64 `json:"last_week_ip_count"`
	LastWeekPVCount int64 `json:"last_week_pv_count"`

	// This month stats
	ThisMonthIPCount int64 `json:"this_month_ip_count"`
	ThisMonthPVCount int64 `json:"this_month_pv_count"`

	// Total stats
	TotalIPCount int64 `json:"total_ip_count"`
	TotalPVCount int64 `json:"total_pv_count"`

	// Average stats
	AvgDailyIPCount   float64 `json:"avg_daily_ip_count"`
	AvgDailyPVCount   float64 `json:"avg_daily_pv_count"`
	AvgWeeklyIPCount  float64 `json:"avg_weekly_ip_count"`
	AvgWeeklyPVCount  float64 `json:"avg_weekly_pv_count"`
	AvgMonthlyIPCount float64 `json:"avg_monthly_ip_count"`
	AvgMonthlyPVCount float64 `json:"avg_monthly_pv_count"`

	// Online visitors
	OnlineVisitors1Min  int64 `json:"online_visitors_1min"`
	OnlineVisitors5Min  int64 `json:"online_visitors_5min"`
	OnlineVisitors15Min int64 `json:"online_visitors_15min"`

	// New vs returning visitors
	NewVisitors       int64 `json:"new_visitors"`
	ReturningVisitors int64 `json:"returning_visitors"`

	// Days since start
	DaysSinceStart int `json:"days_since_start"`
}

// GetWebsiteStats gets comprehensive stats for a website
func (s *StatService) GetWebsiteStats(websiteID int) (*WebsiteStats, error) {
	// Get website to check start time
	website, err := s.websiteRepo.FindByID(websiteID)
	if err != nil {
		return nil, err
	}

	// Calculate time periods
	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	yesterday := today.AddDate(0, 0, -1)

	// Calculate week start (Monday)
	weekday := int(now.Weekday())
	if weekday == 0 { // Sunday
		weekday = 7
	}
	thisWeekStart := today.AddDate(0, 0, -(weekday - 1))
	lastWeekStart := thisWeekStart.AddDate(0, 0, -7)

	// Calculate month start
	thisMonthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	_ = thisMonthStart.AddDate(0, -1, 0) // lastMonthStart - reserved for future use

	// Calculate days since start
	daysSinceStart := int(now.Sub(website.StartTime).Hours() / 24)
	if daysSinceStart < 1 {
		daysSinceStart = 1 // Avoid division by zero
	}

	// Initialize stats object
	stats := &WebsiteStats{
		DaysSinceStart: daysSinceStart,
	}

	// Get today stats
	stats.TodayIPCount, stats.TodayPVCount, err = s.statAnalyticsRepo.GetTodayStats(websiteID, today)
	if err != nil {
		return nil, err
	}

	// Get yesterday stats
	stats.YesterdayIPCount, stats.YesterdayPVCount, err = s.statAnalyticsRepo.GetYesterdayStats(websiteID, yesterday, today)
	if err != nil {
		return nil, err
	}

	// Get this week stats
	stats.ThisWeekIPCount, stats.ThisWeekPVCount, err = s.statAnalyticsRepo.GetWeekStats(websiteID, thisWeekStart)
	if err != nil {
		return nil, err
	}

	// Get last week stats
	stats.LastWeekIPCount, stats.LastWeekPVCount, err = s.statAnalyticsRepo.GetLastWeekStats(websiteID, lastWeekStart, thisWeekStart)
	if err != nil {
		return nil, err
	}

	// Get this month stats
	stats.ThisMonthIPCount, stats.ThisMonthPVCount, err = s.statAnalyticsRepo.GetMonthStats(websiteID, thisMonthStart)
	if err != nil {
		return nil, err
	}

	// Get total stats
	stats.TotalIPCount, stats.TotalPVCount, err = s.statAnalyticsRepo.GetTotalStats(websiteID, website.StartTime)
	if err != nil {
		return nil, err
	}

	// Calculate average stats
	stats.AvgDailyIPCount = float64(stats.TotalIPCount) / float64(daysSinceStart)
	stats.AvgDailyPVCount = float64(stats.TotalPVCount) / float64(daysSinceStart)
	stats.AvgWeeklyIPCount = stats.AvgDailyIPCount * 7
	stats.AvgWeeklyPVCount = stats.AvgDailyPVCount * 7
	stats.AvgMonthlyIPCount = stats.AvgDailyIPCount * 30
	stats.AvgMonthlyPVCount = stats.AvgDailyPVCount * 30

	// Get online visitors
	stats.OnlineVisitors1Min, err = s.statAnalyticsRepo.GetOnlineVisitors(websiteID, 1)
	if err != nil {
		return nil, err
	}

	stats.OnlineVisitors5Min, err = s.statAnalyticsRepo.GetOnlineVisitors(websiteID, 5)
	if err != nil {
		return nil, err
	}

	stats.OnlineVisitors15Min, err = s.statAnalyticsRepo.GetOnlineVisitors(websiteID, 15)
	if err != nil {
		return nil, err
	}

	// Get new vs returning visitors
	stats.NewVisitors, stats.ReturningVisitors, err = s.statAnalyticsRepo.GetNewVsReturningVisitors(websiteID, today)
	if err != nil {
		return nil, err
	}

	return stats, nil
}

// GetSystemTodayStats gets system-wide today's statistics
func (s *StatService) GetSystemTodayStats(date string) (int, int, error) {
	return s.statAnalyticsRepo.GetSystemTodayStats(date)
}

// GetSystemTotalStats gets system-wide total statistics
func (s *StatService) GetSystemTotalStats() (int, int, error) {
	return s.statAnalyticsRepo.GetSystemTotalStats()
}

// GetSystemTrendData gets system-wide trend data for the last N days
func (s *StatService) GetSystemTrendData(days int) ([]repository.DailyStatsData, error) {
	return s.statAnalyticsRepo.GetSystemTrendData(days)
}
