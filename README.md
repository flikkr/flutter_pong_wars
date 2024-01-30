# flutter_pong_wars

An adaptation of Pong Wars using Flutter, inspired by [this project](https://pong-wars.koenvangilst.nl/).

## Introduction

I was at work when someone shared a link to the original project by [vnglst](https://github.com/vnglst) on Slack. I thought that was a cool mini-project and there were versions of it written in Python, C++, but no Flutter! So after arriving home, I decided to try and recreate this in Flutter which was also a good opportunity for me to learn how to use `CustomPainter` to draw to the canvas. I was helped **_a lot_** by Github Copilot and ChatGPT, but I guess that's just how coding in 2024 is ¯\\\_(ツ)\_/¯

The code is based on the [original source code](https://github.com/vnglst/pong-wars/tree/main), without any optimisation in mind.

## Supported platforms

All of them (probably, haven't tested)

- Android
- iOS
- Windows
- macOS
- Linux
- Web

## Improvements and known issues

Feel free to leave an issue or PR addressing any bugs from the list below, or any that you encounter yourself!

- [ ] The balls move slower than in the original project, probably due to Flutter hitting the limit of how frequently the canvas can be repainted. Balls can be made to move faster by increasing the values used to update their positioning.
- [ ] Ball movement is not always smooth and bounces in weird ways.
- [ ] Game is deterministic, i.e. always starts the same way. Would be cool to add some entropy.
- [ ] Score does not update.
