package service

import (
	"errors"
	"net"
	"net/url"
	"strconv"
	"strings"
	"time"

	"aq3stat/internal/model"
	"aq3stat/internal/repository"
)

// CollectorService handles data collection related business logic
type CollectorService struct {
	websiteRepo      *repository.WebsiteRepository
	statRepo         *repository.StatRepository
	ipDataRepo       *repository.IPDataRepository
	searchEngineRepo *repository.SearchEngineRepository
}

// NewCollectorService creates a new collector service
func NewCollectorService() *CollectorService {
	return &CollectorService{
		websiteRepo:      repository.NewWebsiteRepository(),
		statRepo:         repository.NewStatRepository(),
		ipDataRepo:       repository.NewIPDataRepository(),
		searchEngineRepo: repository.NewSearchEngineRepository(),
	}
}

// CollectData collects visitor data
func (s *CollectorService) CollectData(websiteID int, clientIP, referer, location, screenColor, screenSize, userAgent, language string) error {
	// Check if website exists
	_, err := s.websiteRepo.FindByID(websiteID)
	if err != nil {
		return errors.New("website not found")
	}

	// Parse IP address
	ip := net.ParseIP(clientIP)
	if ip == nil {
		return errors.New("invalid IP address")
	}

	// Convert IP to uint32
	ipUint := ipToUint(ip)

	// Get current time
	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	yesterday := today.AddDate(0, 0, -1)

	// Check if this IP has visited today
	existingStat, err := s.statRepo.FindByWebsiteIDAndIP(websiteID, clientIP, today)

	if err == nil {
		// Update existing stat
		existingStat.LeaveTime = now
		existingStat.Count++
		return s.statRepo.Update(existingStat)
	}

	// This is a new visit for today, create a new stat record

	// Parse referer
	var baseReferer, searchEngine, keyword string
	if referer != "" {
		parsedURL, err := url.Parse(referer)
		if err == nil {
			baseReferer = parsedURL.Scheme + "://" + parsedURL.Host

			// Check if referer is a search engine
			searchEngines, _ := s.searchEngineRepo.List()
			for _, se := range searchEngines {
				domains := strings.Split(se.Domains, ",")
				for _, domain := range domains {
					if strings.Contains(baseReferer, strings.TrimSpace(domain)) {
						searchEngine = se.Name

						// Extract search keyword
						queryParams := strings.Split(se.QueryParams, ",")
						for _, param := range queryParams {
							values, err := url.ParseQuery(parsedURL.RawQuery)
							if err == nil {
								keyword = values.Get(strings.TrimSpace(param))
								if keyword != "" {
									break
								}
							}
						}
						break
					}
				}
				if searchEngine != "" {
					break
				}
			}
		}
	}

	// Parse screen color
	screenColorInt, _ := strconv.Atoi(screenColor)

	// Check for Alexa toolbar
	hasAlexaBar := strings.Contains(strings.ToLower(userAgent), "alexa")

	// Get location info from IP
	var address, province, isp string
	ipData, err := s.ipDataRepo.FindByIP(ipUint)
	if err == nil {
		address = ipData.Address1

		// Extract province from address
		if strings.Contains(address, "省") {
			province = address[:strings.Index(address, "省")+3]
		} else if strings.Contains(address, "市") {
			province = address[:strings.Index(address, "市")+3]
		}

		isp = ipData.Address2
	}

	// Determine browser type
	browser := getBrowserType(userAgent)

	// Determine OS type
	os := getOSType(userAgent)

	// Determine OS language
	osLang := getOSLang(language)

	// Check if this IP visited yesterday to determine re-visit times
	reVisitTimes := 1
	yesterdayStat, err := s.statRepo.FindByWebsiteIDAndIPYesterday(websiteID, clientIP, yesterday, today)
	if err == nil {
		reVisitTimes = yesterdayStat.ReVisitTimes + 1
	}

	// Create new stat
	stat := &model.Stat{
		WebsiteID:    websiteID,
		Time:         now,
		LeaveTime:    now,
		IP:           clientIP,
		Count:        1,
		Referer:      referer,
		BaseReferer:  baseReferer,
		SearchEngine: searchEngine,
		Keyword:      keyword,
		Location:     location,
		ScreenColor:  screenColorInt,
		ScreenSize:   screenSize,
		Browser:      browser,
		OS:           os,
		OSLang:       osLang,
		HasAlexaBar:  hasAlexaBar,
		Address:      address,
		Province:     province,
		ISP:          isp,
		ReVisitTimes: reVisitTimes,
	}

	return s.statRepo.Create(stat)
}

// Helper function to convert IP to uint32
func ipToUint(ip net.IP) uint {
	ip = ip.To4()
	if ip == nil {
		return 0
	}

	return uint(ip[0])<<24 | uint(ip[1])<<16 | uint(ip[2])<<8 | uint(ip[3])
}

// Helper function to determine browser type
func getBrowserType(userAgent string) string {
	userAgent = strings.ToLower(userAgent)

	if strings.Contains(userAgent, "msie 6") {
		return "MSIE 6.x"
	} else if strings.Contains(userAgent, "msie 5") {
		return "MSIE 5.x"
	} else if strings.Contains(userAgent, "msie 4") {
		return "MSIE 4.x"
	} else if strings.Contains(userAgent, "netscape") {
		return "Netscape"
	} else if strings.Contains(userAgent, "firefox") {
		return "Firefox"
	} else if strings.Contains(userAgent, "chrome") {
		return "Chrome"
	} else if strings.Contains(userAgent, "safari") {
		return "Safari"
	} else if strings.Contains(userAgent, "opera") {
		return "Opera"
	} else {
		return "Other"
	}
}

// Helper function to determine OS type
func getOSType(userAgent string) string {
	userAgent = strings.ToLower(userAgent)

	if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "98") {
		return "Windows 98"
	} else if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "nt 5.0") {
		return "Windows 2000"
	} else if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "nt 5.1") {
		return "Windows XP"
	} else if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "nt 5.2") {
		return "Windows 2003"
	} else if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "nt 6.0") {
		return "Windows Vista"
	} else if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "nt 6.1") {
		return "Windows 7"
	} else if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "nt 6.2") {
		return "Windows 8"
	} else if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "nt 6.3") {
		return "Windows 8.1"
	} else if strings.Contains(userAgent, "win") && strings.Contains(userAgent, "nt 10.0") {
		return "Windows 10"
	} else if strings.Contains(userAgent, "linux") {
		return "Linux"
	} else if strings.Contains(userAgent, "unix") {
		return "Unix"
	} else if strings.Contains(userAgent, "mac") {
		return "Mac OS"
	} else {
		return "Other"
	}
}

// Helper function to determine OS language
func getOSLang(language string) string {
	language = strings.ToLower(language)

	if strings.Contains(language, "zh-cn") {
		return "zh-cn"
	} else if strings.Contains(language, "zh-tw") {
		return "zh-tw"
	} else if strings.Contains(language, "en") {
		return "en"
	} else {
		return "other"
	}
}
