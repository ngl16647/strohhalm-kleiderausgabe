package cfg

import (
	"crypto/rand"
	"flag"
	"fmt"
	"log"
	"math/big"
	"os"

	"go.yaml.in/yaml/v3"
)

var configPath = "./config.yml"

type Config struct {
	Server struct {
		Host string
		Port int
	}
	Api struct {
		UseApiKey bool   `yaml:"use_api_key"`
		ApiKey    string `yaml:"api_key"`
	}
	Data string
}

var GlobalConfig *Config = defaultConfig()

func defaultConfig() *Config {
	cfg := &Config{}
	cfg.Server.Host = "0.0.0.0"
	cfg.Server.Port = 8080
	cfg.Api.UseApiKey = false
	cfg.Data = "data.db"
	return cfg
}

func InitConfig() {
	var rewriteConfigFile = false
	// check if config file exists
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		rewriteConfigFile = true
	} else {
		// when config file exists, load it
		if err := loadConfig(configPath, GlobalConfig); err != nil {
			log.Fatal(err)
		}
	}

	// flags
	flag.StringVar(&GlobalConfig.Server.Host, "host", GlobalConfig.Server.Host, "Server host")
	flag.IntVar(&GlobalConfig.Server.Port, "port", GlobalConfig.Server.Port, "Server port")

	noKey := flag.Bool("no-key", false, "Turn off API key verification")
	newKey := flag.Bool("new-key", false, "Generate new API key")
	docsFlag := flag.Bool("docs", false, "Print API documentation")

	flag.Parse()

	if *noKey {
		GlobalConfig.Api.UseApiKey = false
	}

	// print docs if --docs flag is on
	if *docsFlag {
		printAPIDocs()
		os.Exit(0) // do not run the server
	}

	if GlobalConfig.Api.UseApiKey {
		if GlobalConfig.Api.ApiKey == "" || *newKey {
			var err error
			GlobalConfig.Api.ApiKey, err = keyOfLength(16)
			if err != nil {
				log.Fatal("Unable to generate new keys")
			}
			fmt.Println("API key: ", GlobalConfig.Api.ApiKey)
			rewriteConfigFile = true
		}
	} else {
		log.Println("WARNING: Server running without API key verification")
	}

	if rewriteConfigFile {
		data, err := yaml.Marshal(&GlobalConfig)
		if err != nil {
			log.Fatal(err)
		}

		if err := os.WriteFile(configPath, data, 0644); err != nil {
			log.Fatal(err)
		}

		fmt.Println("Config file updated")
	}
}

func loadConfig(path string, cfg *Config) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("reading config file: %w", err)
	}

	if err := yaml.Unmarshal(data, cfg); err != nil {
		return fmt.Errorf("parsing config file: %w", err)
	}

	return nil
}

func keyOfLength(length int) (string, error) {
	const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	length += length/4 - 1 // make space for dashes
	key := make([]byte, length)
	for i := 0; i < length; i++ {
		if i%5 == 4 && i != length-1 {
			key[i] = '-'
			continue
		}

		num, err := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
		if err != nil {
			return "", err
		}
		key[i] = charset[num.Int64()]
	}
	return string(key), nil
}
