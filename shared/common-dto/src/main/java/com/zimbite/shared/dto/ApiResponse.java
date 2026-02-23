package com.zimbite.shared.dto;

public record ApiResponse<T>(String traceId, T data) {
}
