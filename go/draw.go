package utils

import (
	"errors"
	"image"
	"image/color"
	"image/png"
	"os"
)

func Draw(filePath string, width int, height int, tryDraw func(i int) (bool, int)) error {
	if tryDraw == nil {
		return errors.New("invalid tryDraw.")
	}

	c := NewCanvas(width, height)
	for i := 0; i < c.Width(); i++ {
		needDraw, j := tryDraw(i)
		if needDraw {
			c.DrawPoint(i, j)
		}
	}
	c.GenerateImgFile(filePath)
	return nil
}

type Canvas struct {
	width, height int
	pixels        []color.RGBA
}

const (
	FileTail    = ".png"
	FileTailLen = len(FileTail)
)

func NewCanvas(width int, height int) *Canvas {
	return &Canvas{
		width:  width,
		height: height,
		pixels: make([]color.RGBA, width*height),
	}
}

func (c *Canvas) Width() int {
	return c.width
}

func (c *Canvas) Height() int {
	return c.height
}

func (c *Canvas) DrawPoint(x int, y int) {
	if x < 0 || x >= c.width {
		return
	}

	if y < 0 || y >= c.height {
		return
	}

	index := y*c.width + x
	c.pixels[index] = color.RGBA{0, 255, 0, 255}
}

func (c *Canvas) GenerateImgFile(path string) error {
	if len(path) == 0 {
		return errors.New("invalid file path.")
	}

	if len(path) < FileTailLen || path[len(path)-4:] != FileTail {
		path += FileTail
	}

	file, err := os.Create(path)
	if err != nil {
		return err
	}

	rect := image.Rect(0, 0, c.width, c.height)
	outputImage := image.NewRGBA(rect)
	for x := 0; x < c.width; x++ {
		for y := 0; y < c.height; y++ {
			outputImage.SetRGBA(x, c.height-1-y, c.pixels[y*c.width+x])
		}
	}

	png.Encode(file, outputImage)
	return nil
}
