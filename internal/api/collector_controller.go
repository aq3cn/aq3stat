package api

import (
	"net/http"
	"strconv"

	"aq3stat/internal/service"
	"github.com/gin-gonic/gin"
)

// CollectorController handles data collection related API endpoints
type CollectorController struct {
	collectorService *service.CollectorService
}

// NewCollectorController creates a new collector controller
func NewCollectorController() *CollectorController {
	return &CollectorController{
		collectorService: service.NewCollectorService(),
	}
}

// Counter generates the JavaScript tracking code
func (c *CollectorController) Counter(ctx *gin.Context) {
	idStr := ctx.Query("id")
	_, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.String(http.StatusBadRequest, "Invalid website ID")
		return
	}

	iconType := ctx.DefaultQuery("icon", "1")

	// Set content type to JavaScript
	ctx.Header("Content-Type", "application/javascript")

	// Generate JavaScript code
	baseURL := "http://" + ctx.Request.Host // Use actual host from request

	// Generate JavaScript code that supports both sync and async loading
	js := `
(function() {
  var aq3stat_base_url = "` + baseURL + `";

  // Function to create and append elements (works for both sync and async)
  function aq3stat_createElement(tag, attributes, content) {
    var element = document.createElement(tag);
    if (attributes) {
      for (var attr in attributes) {
        element.setAttribute(attr, attributes[attr]);
      }
    }
    if (content) {
      element.innerHTML = content;
    }
    return element;
  }

  // Function to append element to document
  function aq3stat_appendElement(element) {
    // Try to find the script tag that loaded this code
    var scripts = document.getElementsByTagName('script');
    var currentScript = scripts[scripts.length - 1];

    // If we can find the current script, insert after it
    if (currentScript && currentScript.parentNode) {
      currentScript.parentNode.insertBefore(element, currentScript.nextSibling);
    } else {
      // Fallback: append to body or head
      var target = document.body || document.head || document.documentElement;
      if (target) {
        target.appendChild(element);
      }
    }
  }
`

	// Add icon display code based on icon type
	if iconType == "no" {
		js += `
  // Create text node for "统计中"
  var textNode = document.createTextNode("统计中");
  aq3stat_appendElement(textNode);`
	} else if iconType == "text" {
		color := ctx.DefaultQuery("color", "#000000")
		js += `
  // Create text display with stats
  var statsLink = aq3stat_createElement('a', {
    'href': aq3stat_base_url + '/stats/` + idStr + `',
    'target': '_blank',
    'title': 'aq3stat统计'
  });
  var statsText = aq3stat_createElement('font', {'color': '` + color + `'}, '网站统计');
  statsLink.appendChild(statsText);

  var statsInfo = aq3stat_createElement('font', {'color': '` + color + `'}, ' | 今日IP[100] | 今日PV[500] | 昨日IP[80] | 昨日PV[400] | 当前在线[10]');

  var container = aq3stat_createElement('span');
  container.appendChild(statsLink);
  container.appendChild(statsInfo);
  aq3stat_appendElement(container);`
	} else if iconType == "mark" {
		color := ctx.DefaultQuery("color", "#000000")
		js += `
  // Create mark display
  var markLink = aq3stat_createElement('a', {
    'href': aq3stat_base_url + '/stats/` + idStr + `',
    'target': '_blank',
    'title': 'aq3stat统计'
  });
  var markText = aq3stat_createElement('font', {'color': '` + color + `'}, '网站统计');
  markLink.appendChild(markText);
  aq3stat_appendElement(markLink);`
	} else {
		// Use icon image
		js += `
  // Create icon image
  var iconLink = aq3stat_createElement('a', {
    'href': aq3stat_base_url + '/stats/` + idStr + `',
    'target': '_blank',
    'title': 'aq3stat统计'
  });
  var iconImg = aq3stat_createElement('img', {
    'src': aq3stat_base_url + '/static/icons/` + iconType + `.gif',
    'style': 'border-width:0'
  });
  iconLink.appendChild(iconImg);
  aq3stat_appendElement(iconLink);`
	}

	// Add tracking code
	js += `

  // Create tracking iframe
  var aq3stat_url = aq3stat_base_url + "/collect?id=` + idStr + `";
  aq3stat_url += "&referer=" + encodeURIComponent(document.referrer);
  aq3stat_url += "&location=" + encodeURIComponent(document.location);
  aq3stat_url += "&color=" + screen.colorDepth;
  aq3stat_url += "&width=" + screen.width;
  aq3stat_url += "&height=" + screen.height;
  if(typeof(navigator.systemLanguage) != "undefined") aq3stat_url += "&lang=" + navigator.systemLanguage;

  var trackingFrame = aq3stat_createElement('iframe', {
    'src': aq3stat_url,
    'width': '0',
    'height': '0',
    'marginwidth': '0',
    'marginheight': '0',
    'hspace': '0',
    'vspace': '0',
    'frameborder': '0',
    'scrolling': 'no',
    'style': 'display:none;'
  });
  aq3stat_appendElement(trackingFrame);
})();`

	ctx.String(http.StatusOK, js)
}

// Collect collects visitor data
func (c *CollectorController) Collect(ctx *gin.Context) {
	idStr := ctx.Query("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		ctx.String(http.StatusBadRequest, "Invalid website ID")
		return
	}

	// Get client IP
	clientIP := ctx.ClientIP()

	// Get other parameters
	referer := ctx.Query("referer")
	location := ctx.Query("location")
	screenColor := ctx.Query("color")
	screenWidth := ctx.Query("width")
	screenHeight := ctx.Query("height")
	language := ctx.Query("lang")

	// Combine width and height for screen size
	screenSize := screenWidth + "X" + screenHeight

	// Get user agent
	userAgent := ctx.Request.UserAgent()

	// Collect data
	err = c.collectorService.CollectData(
		id,
		clientIP,
		referer,
		location,
		screenColor,
		screenSize,
		userAgent,
		language,
	)

	if err != nil {
		// Just return a transparent 1x1 pixel GIF
		ctx.Data(http.StatusOK, "image/gif", transparentGIF())
		return
	}

	// Return a transparent 1x1 pixel GIF
	ctx.Data(http.StatusOK, "image/gif", transparentGIF())
}

// transparentGIF returns a transparent 1x1 pixel GIF
func transparentGIF() []byte {
	return []byte{
		0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00, 0x00, 0xFF, 0xFF, 0xFF,
		0x00, 0x00, 0x00, 0x21, 0xF9, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x2C, 0x00, 0x00, 0x00, 0x00,
		0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3B,
	}
}
