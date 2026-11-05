# Native iOS System-Language English Localization (`fr` / `en`) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Automatically switch MeemawQuizz (UI, Question Bank, Drawing Bank, Punchlines, Web QR Controller, and Meemaw Studio Voice `.m4a` + TTS) between French and English based on the iOS system language (`Locale.preferredLanguages`), with zero flag buttons in the UI, and ship Build 7 to TestFlight.

**Architecture:** Declare `CFBundleLocalizations` (`fr`, `en`) in `App/Info.plist` and `project.yml`, add `AppLanguage` (`.fr`, `.en`) resolved from `Locale.preferredLanguages` in `MeemawQuizzCore`, create `QuestionBankEnglish.swift` with culturally adapted Sassy Grandma English questions, sponsors, Juste Pif, Raclette, Jack Attack, and drawings, generate neural English `.m4a` studio voice cues, localize UI & Web controller strings, and deploy Build 7 to TestFlight.

**Tech Stack:** Swift 6 (`MeemawQuizzCore` + iOS SwiftUI), `AVFoundation`, `edge-tts` + `ffmpeg` for neural English `.m4a` studio voice cues, App Store Connect API (`Build 7`).
