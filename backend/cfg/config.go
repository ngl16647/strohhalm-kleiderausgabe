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
	Tls struct {
		UseTls   bool   `yaml:"use_tls"`
		CertFile string `yaml:"cert_file"`
		KeyFile  string `yaml:"key_file"`
	}
	Data string
}

var GlobalConfig *Config = defaultConfig()

func defaultConfig() *Config {
	cfg := &Config{}
	cfg.Server.Host = "0.0.0.0"
	cfg.Server.Port = 8080

	cfg.Api.UseApiKey = true

	cfg.Tls.UseTls = false
	cfg.Tls.CertFile = "cert/cert.pem"
	cfg.Tls.KeyFile = "cert/key.pem"

	cfg.Data = "data.db"
	return cfg
}

func InitConfig() {
	var rewriteConfigFile = false
	// load existing config file
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		rewriteConfigFile = true
	} else {
		loadConfig(configPath, GlobalConfig)
	}

	// flags
	flag.StringVar(&GlobalConfig.Server.Host, "host", GlobalConfig.Server.Host, "Server host")
	flag.IntVar(&GlobalConfig.Server.Port, "port", GlobalConfig.Server.Port, "Server port")

	noKey := flag.Bool("no-key", false, "Turn off API key verification")
	newKey := flag.Bool("new-key", false, "Generate new API key")
	useTls := flag.Bool("tls", false, "Use TLS")
	docsFlag := flag.Bool("docs", false, "Print API documentation")

	flag.Parse()

	// print docs if --docs flag is on
	if *docsFlag {
		printAPIDocs()
		os.Exit(0) // do not run the server
	}

	// generate new API key
	if !*noKey {
		if GlobalConfig.Api.ApiKey == "" || *newKey {
			var err error
			GlobalConfig.Api.ApiKey, err = keyOfLength(16)
			if err != nil {
				log.Fatal("Unable to generate new keys")
			}
			fmt.Println("API key: ", GlobalConfig.Api.ApiKey)
			rewriteConfigFile = true
		}
	}

	// update config file when not exists or new API key is generated
	if rewriteConfigFile {
		writeConfig(configPath, GlobalConfig)
	}

	// adjust global config object for startup
	if *noKey {
		GlobalConfig.Api.UseApiKey = false
	}
	if *useTls {
		GlobalConfig.Tls.UseTls = *useTls
	}

}

func loadConfig(path string, cfg *Config) {
	data, err := os.ReadFile(path)
	if err != nil {
		log.Fatalf("reading config file: %s", err)
	}

	if err := yaml.Unmarshal(data, cfg); err != nil {
		log.Fatalf("parsing config file: %s", err)
	}
}

func writeConfig(path string, cfg *Config) {
	data, err := yaml.Marshal(cfg)
	if err != nil {
		log.Fatal(err)
	}

	if err := os.WriteFile(path, data, 0644); err != nil {
		log.Fatal(err)
	}

	fmt.Println("Config file updated")
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
