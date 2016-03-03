package scan

import (
	"os"
	"strings"
	"path/filepath"
)

type FileInfo struct {
	Name string
	Path string
}
type FileInfos []*FileInfo
type FileTypes []string

func Walk(startPath string, fileTypes FileTypes, fileInfos FileInfos) (FileInfos) {
	if fileInfos == nil {
		fileInfos = FileInfos{}
	}
	filepath.Walk(startPath, func(path string, f os.FileInfo, err error) error {
            if f == nil {
            	return err
            }

            if f.IsDir() {
            	return nil
            }

            fname := f.Name()
            if containFileType(fname, fileTypes) {
            	fileInfos = append(fileInfos, &FileInfo{fname, path[:(len(path) - len(fname))]})
            }
            return nil
        })
	return fileInfos
}

func containFileType(name string, fileTypes FileTypes) bool {
	if fileTypes == nil {
		return true
	}

	if len(fileTypes) == 0 {
		return true
	}

	for _, t := range fileTypes {
		if t == "." {
			return true
		}

		if strings.HasSuffix(name, t) {
			return true
		}
	}
	return false
}