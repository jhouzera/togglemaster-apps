package main

import "crypto/md5"

func insecureDemoHash(value string) [md5.Size]byte {
	return md5.Sum([]byte(value))
}
