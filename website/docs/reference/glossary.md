---
sidebar_position: 7
title: Glossary
---

# Glossary

Plain-language definitions for the framework-specific terms used throughout these docs. If you hit an unfamiliar term elsewhere, it should link back here.

## SSOT

Short for **Single Source of Truth**. It's the one canonical, authoritative copy of the framework's content — the actual instructions, procedures, and workflow definitions. Everything a specific tool (Cursor, Claude Code) reads is either a direct copy or a generated packaging of this one source, so a change only ever needs to be made in one place.

## Adapters

The layer that takes the canonical content and turns it into the exact files each AI coding tool expects — for example, generating a Cursor-readable rule file or a Claude Code command file from the same source instructions. Adapters don't own or duplicate the content itself; they package it for a specific tool.

## MCP

Short for **Model Context Protocol**. It's a standard way for an AI tool to connect to outside services and data — like a ticket tracker, a design tool, or a documentation search — so the AI can look things up or take actions during a conversation, instead of only working from what you typed.
