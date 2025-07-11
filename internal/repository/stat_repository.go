package repository

import (
	"time"

	"aq3stat/internal/model"
	"aq3stat/pkg/database"
	"gorm.io/gorm"
)

// StatAnalyticsRepository handles database operations for stat analytics
type StatAnalyticsRepository struct {
	db *gorm.DB
}

// NewStatAnalyticsRepository creates a new stat analytics repository
func NewStatAnalyticsRepository() *StatAnalyticsRepository {
	return &StatAnalyticsRepository{
		db: database.DB,
	}
}

// GetTodayStats gets today's stats for a website
func (r *StatAnalyticsRepository) GetTodayStats(websiteID int, today time.Time) (int64, int64, error) {
	var ipCount, pvCount int64

	// Get IP count (unique visitors)
	err := r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ?", websiteID, today).Count(&ipCount).Error
	if err != nil {
		return 0, 0, err
	}

	// Get PV count (page views)
	err = r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ?", websiteID, today).Select("COALESCE(SUM(count), 0)").Row().Scan(&pvCount)
	if err != nil {
		return 0, 0, err
	}

	return ipCount, pvCount, nil
}

// GetYesterdayStats gets yesterday's stats for a website
func (r *StatAnalyticsRepository) GetYesterdayStats(websiteID int, yesterday, today time.Time) (int64, int64, error) {
	var ipCount, pvCount int64

	// Get IP count (unique visitors)
	err := r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ? AND time < ?", websiteID, yesterday, today).Count(&ipCount).Error
	if err != nil {
		return 0, 0, err
	}

	// Get PV count (page views)
	err = r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ? AND time < ?", websiteID, yesterday, today).Select("COALESCE(SUM(count), 0)").Row().Scan(&pvCount)
	if err != nil {
		return 0, 0, err
	}

	return ipCount, pvCount, nil
}

// GetOnlineVisitors gets the number of online visitors in the last N minutes
func (r *StatAnalyticsRepository) GetOnlineVisitors(websiteID int, minutes int) (int64, error) {
	var count int64

	timeAgo := time.Now().Add(-time.Duration(minutes) * time.Minute)

	err := r.db.Model(&model.Stat{}).
		Where("website_id = ? AND leave_time >= ?", websiteID, timeAgo).
		Distinct("ip").
		Count(&count).Error

	return count, err
}

// GetNewVsReturningVisitors gets the count of new vs returning visitors for today
func (r *StatAnalyticsRepository) GetNewVsReturningVisitors(websiteID int, today time.Time) (int64, int64, error) {
	var newVisitors, returningVisitors int64

	// New visitors (re_visit_times = 1)
	err := r.db.Model(&model.Stat{}).
		Where("website_id = ? AND time >= ? AND re_visit_times = 1", websiteID, today).
		Count(&newVisitors).Error
	if err != nil {
		return 0, 0, err
	}

	// Returning visitors (re_visit_times > 1)
	err = r.db.Model(&model.Stat{}).
		Where("website_id = ? AND time >= ? AND re_visit_times > 1", websiteID, today).
		Count(&returningVisitors).Error

	return newVisitors, returningVisitors, err
}

// GetWeekStats gets this week's stats for a website
func (r *StatAnalyticsRepository) GetWeekStats(websiteID int, weekStart time.Time) (int64, int64, error) {
	var ipCount, pvCount int64

	// Get IP count (unique visitors)
	err := r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ?", websiteID, weekStart).Count(&ipCount).Error
	if err != nil {
		return 0, 0, err
	}

	// Get PV count (page views)
	err = r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ?", websiteID, weekStart).Select("COALESCE(SUM(count), 0)").Row().Scan(&pvCount)
	if err != nil {
		return 0, 0, err
	}

	return ipCount, pvCount, nil
}

// GetLastWeekStats gets last week's stats for a website
func (r *StatAnalyticsRepository) GetLastWeekStats(websiteID int, lastWeekStart, thisWeekStart time.Time) (int64, int64, error) {
	var ipCount, pvCount int64

	// Get IP count (unique visitors)
	err := r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ? AND time < ?", websiteID, lastWeekStart, thisWeekStart).Count(&ipCount).Error
	if err != nil {
		return 0, 0, err
	}

	// Get PV count (page views)
	err = r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ? AND time < ?", websiteID, lastWeekStart, thisWeekStart).Select("COALESCE(SUM(count), 0)").Row().Scan(&pvCount)
	if err != nil {
		return 0, 0, err
	}

	return ipCount, pvCount, nil
}

// GetMonthStats gets this month's stats for a website
func (r *StatAnalyticsRepository) GetMonthStats(websiteID int, monthStart time.Time) (int64, int64, error) {
	var ipCount, pvCount int64

	// Get IP count (unique visitors)
	err := r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ?", websiteID, monthStart).Count(&ipCount).Error
	if err != nil {
		return 0, 0, err
	}

	// Get PV count (page views)
	err = r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ?", websiteID, monthStart).Select("COALESCE(SUM(count), 0)").Row().Scan(&pvCount)
	if err != nil {
		return 0, 0, err
	}

	return ipCount, pvCount, nil
}

// GetTotalStats gets total stats for a website since start
func (r *StatAnalyticsRepository) GetTotalStats(websiteID int, startTime time.Time) (int64, int64, error) {
	var ipCount, pvCount int64

	// Get IP count (unique visitors)
	err := r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ?", websiteID, startTime).Count(&ipCount).Error
	if err != nil {
		return 0, 0, err
	}

	// Get PV count (page views)
	err = r.db.Model(&model.Stat{}).Where("website_id = ? AND time >= ?", websiteID, startTime).Select("COALESCE(SUM(count), 0)").Row().Scan(&pvCount)
	if err != nil {
		return 0, 0, err
	}

	return ipCount, pvCount, nil
}

// GetSystemTodayStats gets system-wide today's statistics
func (r *StatAnalyticsRepository) GetSystemTodayStats(date string) (int, int, error) {
	var ipCount, pvCount int64

	// Parse date
	today, err := time.Parse("2006-01-02", date)
	if err != nil {
		return 0, 0, err
	}
	tomorrow := today.AddDate(0, 0, 1)

	// Get IP count (unique visitors across all websites)
	err = r.db.Model(&model.Stat{}).
		Where("time >= ? AND time < ?", today, tomorrow).
		Distinct("ip").
		Count(&ipCount).Error
	if err != nil {
		return 0, 0, err
	}

	// Get PV count (page views across all websites)
	err = r.db.Model(&model.Stat{}).
		Where("time >= ? AND time < ?", today, tomorrow).
		Select("COALESCE(SUM(count), 0)").
		Row().Scan(&pvCount)
	if err != nil {
		return 0, 0, err
	}

	return int(ipCount), int(pvCount), nil
}

// GetSystemTotalStats gets system-wide total statistics
func (r *StatAnalyticsRepository) GetSystemTotalStats() (int, int, error) {
	var ipCount, pvCount int64

	// Get total unique IP count across all websites
	err := r.db.Model(&model.Stat{}).
		Distinct("ip").
		Count(&ipCount).Error
	if err != nil {
		return 0, 0, err
	}

	// Get total PV count across all websites
	err = r.db.Model(&model.Stat{}).
		Select("COALESCE(SUM(count), 0)").
		Row().Scan(&pvCount)
	if err != nil {
		return 0, 0, err
	}

	return int(ipCount), int(pvCount), nil
}

// DailyStatsData represents daily statistics data
type DailyStatsData struct {
	Date string `json:"date"`
	PV   int    `json:"pv"`
	IP   int    `json:"ip"`
}

// GetSystemTrendData gets system-wide trend data for the last N days
func (r *StatAnalyticsRepository) GetSystemTrendData(days int) ([]DailyStatsData, error) {
	var results []DailyStatsData

	// Generate date range
	now := time.Now()
	for i := days - 1; i >= 0; i-- {
		date := now.AddDate(0, 0, -i)
		dateStr := date.Format("2006-01-02")
		dayStart := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
		dayEnd := dayStart.AddDate(0, 0, 1)

		var ipCount, pvCount int64

		// Get IP count for this day
		err := r.db.Model(&model.Stat{}).
			Where("time >= ? AND time < ?", dayStart, dayEnd).
			Distinct("ip").
			Count(&ipCount).Error
		if err != nil {
			return nil, err
		}

		// Get PV count for this day
		err = r.db.Model(&model.Stat{}).
			Where("time >= ? AND time < ?", dayStart, dayEnd).
			Select("COALESCE(SUM(count), 0)").
			Row().Scan(&pvCount)
		if err != nil {
			return nil, err
		}

		results = append(results, DailyStatsData{
			Date: dateStr,
			IP:   int(ipCount),
			PV:   int(pvCount),
		})
	}

	return results, nil
}

// RefererStatsData represents referer statistics data
type RefererStatsData struct {
	Name  string `json:"name"`
	Value int64  `json:"value"`
}

// DeviceStatsData represents device statistics data
type DeviceStatsData struct {
	Name  string `json:"name"`
	Value int64  `json:"value"`
}

// GetRefererStats gets referer statistics for a website
func (r *StatAnalyticsRepository) GetRefererStats(websiteID int) ([]RefererStatsData, error) {
	var results []RefererStatsData

	// Query to get referer statistics
	rows, err := r.db.Raw(`
		SELECT
			CASE
				WHEN referer = '' OR referer IS NULL THEN '直接访问'
				WHEN referer LIKE '%google%' OR referer LIKE '%bing%' OR referer LIKE '%baidu%' OR referer LIKE '%yahoo%' THEN '搜索引擎'
				WHEN referer LIKE '%facebook%' OR referer LIKE '%twitter%' OR referer LIKE '%weibo%' OR referer LIKE '%qq%' THEN '社交媒体'
				ELSE '外部链接'
			END as name,
			SUM(count) as value
		FROM stats
		WHERE website_id = ?
		GROUP BY name
		ORDER BY value DESC
		LIMIT 10
	`, websiteID).Rows()

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var item RefererStatsData
		if err := rows.Scan(&item.Name, &item.Value); err != nil {
			return nil, err
		}
		results = append(results, item)
	}

	return results, nil
}

// GetDeviceStats gets device statistics for a website
func (r *StatAnalyticsRepository) GetDeviceStats(websiteID int) ([]DeviceStatsData, error) {
	var results []DeviceStatsData

	// Query to get device statistics based on browser and OS
	rows, err := r.db.Raw(`
		SELECT
			CASE
				WHEN os LIKE '%Windows%' OR os LIKE '%Mac%' OR os LIKE '%Linux%' THEN 'PC'
				WHEN os LIKE '%Android%' OR os LIKE '%iOS%' OR os LIKE '%iPhone%' THEN '移动设备'
				WHEN os LIKE '%iPad%' THEN '平板'
				ELSE '其他'
			END as name,
			SUM(count) as value
		FROM stats
		WHERE website_id = ? AND os IS NOT NULL AND os != ''
		GROUP BY name
		ORDER BY value DESC
	`, websiteID).Rows()

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var item DeviceStatsData
		if err := rows.Scan(&item.Name, &item.Value); err != nil {
			return nil, err
		}
		results = append(results, item)
	}

	return results, nil
}