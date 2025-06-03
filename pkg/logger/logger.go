package logger

import (
	"log"
	"os"
)

var (
	InfoLogger  *log.Logger
	ErrorLogger *log.Logger
	DebugLogger *log.Logger
)

// InitLogger initializes the loggers
func InitLogger() {
	// Create log file
	file, err := os.OpenFile("logs/app.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0666)
	if err != nil {
		log.Fatal(err)
	}

	// Initialize loggers
	InfoLogger = log.New(file, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile)
	ErrorLogger = log.New(file, "ERROR: ", log.Ldate|log.Ltime|log.Lshortfile)
	DebugLogger = log.New(file, "DEBUG: ", log.Ldate|log.Ltime|log.Lshortfile)

	// Also log to stdout in development environment
	if os.Getenv("ENV") == "development" {
		InfoLogger.SetOutput(os.Stdout)
		ErrorLogger.SetOutput(os.Stderr)
		DebugLogger.SetOutput(os.Stdout)
	}
}

// Info logs info messages
func Info(format string, v ...interface{}) {
	InfoLogger.Printf(format, v...)
}

// Error logs error messages
func Error(format string, v ...interface{}) {
	ErrorLogger.Printf(format, v...)
}

// Debug logs debug messages
func Debug(format string, v ...interface{}) {
	if os.Getenv("ENV") == "development" {
		DebugLogger.Printf(format, v...)
	}
}
