from fastapi import HTTPException, Request, Response
from fastapi.responses import JSONResponse
import time
from collections import defaultdict, deque
from typing import Dict, Deque, Tuple
import asyncio
from datetime import datetime, timedelta

class RateLimiter:
    def __init__(
        self, 
        requests_per_minute: int = 30,
        requests_per_hour: int = 500,
        requests_per_day: int = 200,
        burst_size: int = 10
    ):
        self.requests_per_minute = requests_per_minute
        self.requests_per_hour = requests_per_hour
        self.requests_per_day = requests_per_day
        self.burst_size = burst_size
        
        # Store request timestamps for each IP
        # Maxlen should be able to hold a day's worth of requests
        self.request_times: Dict[str, Deque[float]] = defaultdict(lambda: deque(maxlen=max(requests_per_day, requests_per_hour)))
        
        # Store burst tracking
        self.burst_tracking: Dict[str, Tuple[int, float]] = {}
        
        # Lock for thread-safe operations
        self.lock = asyncio.Lock()
        
        # Track if system is under heavy load
        self.system_load_threshold = 0.8  # 80% of capacity
        self.is_high_load = False
        
    async def check_rate_limit(self, client_ip: str) -> Tuple[bool, str]:
        """
        Check if the client has exceeded rate limits
        Returns: (is_allowed, error_message)
        """
        async with self.lock:
            current_time = time.time()
            
            # Clean old entries
            self._clean_old_entries(client_ip, current_time)
            
            # Get request history
            request_history = self.request_times[client_ip]
            
            # Check minute rate limit
            minute_ago = current_time - 60
            recent_requests = sum(1 for t in request_history if t > minute_ago)
            
            if recent_requests >= self.requests_per_minute:
                self._update_load_status()
                return False, self._get_rate_limit_message("minute", self.requests_per_minute)
            
            # Check hourly rate limit
            hour_ago = current_time - 3600
            hourly_requests = sum(1 for t in request_history if t > hour_ago)
            
            if hourly_requests >= self.requests_per_hour:
                self._update_load_status()
                return False, self._get_rate_limit_message("hour", self.requests_per_hour)
            
            # Check daily rate limit
            day_ago = current_time - 86400  # 24 hours in seconds
            daily_requests = sum(1 for t in request_history if t > day_ago)
            
            if daily_requests >= self.requests_per_day:
                self._update_load_status()
                return False, self._get_rate_limit_message("day", self.requests_per_day)
            
            # Check burst limit
            if not self._check_burst_limit(client_ip, current_time):
                return False, "Too many requests in a short time. Please slow down your requests."
            
            # Record the request
            request_history.append(current_time)
            self._update_load_status()
            
            return True, ""
    
    def _clean_old_entries(self, client_ip: str, current_time: float):
        """Remove entries older than 24 hours"""
        day_ago = current_time - 86400  # 24 hours
        request_history = self.request_times[client_ip]
        
        # Remove old entries
        while request_history and request_history[0] < day_ago:
            request_history.popleft()
    
    def _check_burst_limit(self, client_ip: str, current_time: float) -> bool:
        """Check if client is making burst requests"""
        if client_ip not in self.burst_tracking:
            self.burst_tracking[client_ip] = (1, current_time)
            return True
        
        count, last_time = self.burst_tracking[client_ip]
        
        # Reset burst tracking if more than 10 seconds have passed
        if current_time - last_time > 10:
            self.burst_tracking[client_ip] = (1, current_time)
            return True
        
        # Check if within burst window (1 second)
        if current_time - last_time <= 1:
            if count >= self.burst_size:
                return False
            self.burst_tracking[client_ip] = (count + 1, last_time)
        else:
            self.burst_tracking[client_ip] = (1, current_time)
        
        return True
    
    def _update_load_status(self):
        """Update system load status based on current request volume"""
        total_recent_requests = sum(
            len(requests) for requests in self.request_times.values()
        )
        max_capacity = len(self.request_times) * self.requests_per_minute
        
        if max_capacity > 0:
            load_ratio = total_recent_requests / max_capacity
            self.is_high_load = load_ratio >= self.system_load_threshold
    
    def _get_rate_limit_message(self, period: str, limit: int) -> str:
        """Generate appropriate rate limit message based on system load"""
        if self.is_high_load:
            return (
                f"I'm currently experiencing high load. Please try again in a few moments. "
                f"(Maximum {limit} requests per {period})"
            )
        else:
            return (
                f"Rate limit exceeded. You can make up to {limit} requests per {period}. "
                f"Please wait before making more requests."
            )
    
    def get_rate_limit_headers(self, client_ip: str) -> dict:
        """Get rate limit headers for response"""
        current_time = time.time()
        minute_ago = current_time - 60
        
        request_history = self.request_times.get(client_ip, deque())
        recent_requests = sum(1 for t in request_history if t > minute_ago)
        
        remaining = max(0, self.requests_per_minute - recent_requests)
        
        # Calculate reset time (next minute boundary)
        reset_time = int(current_time) + (60 - int(current_time) % 60)
        
        return {
            "X-RateLimit-Limit": str(self.requests_per_minute),
            "X-RateLimit-Remaining": str(remaining),
            "X-RateLimit-Reset": str(reset_time),
        }


import os

# Global rate limiter instance with configurable limits
# More lenient defaults for development
rate_limiter = RateLimiter(
    requests_per_minute=int(os.getenv("RATE_LIMIT_PER_MINUTE", "10")),  # Allow more requests per minute
    requests_per_hour=int(os.getenv("RATE_LIMIT_PER_HOUR", "100")),    # Generous hourly limit
    requests_per_day=int(os.getenv("RATE_LIMIT_PER_DAY", "500")),      # Higher daily limit
    burst_size=int(os.getenv("RATE_LIMIT_BURST_SIZE", "5"))           # Allow more burst requests
)


async def rate_limit_middleware(request: Request, call_next):
    """Middleware to enforce rate limiting"""
    # Get client IP
    client_ip = request.client.host
    
    # Use forwarded IP if behind proxy
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for:
        client_ip = forwarded_for.split(",")[0].strip()
    
    # Debug logging
    print(f"🔍 Rate limiter: {request.method} {request.url.path} from {client_ip}")
    
    # Skip rate limiting for health check endpoints
    if request.url.path in ["/health", "/", "/docs", "/openapi.json"]:
        print(f"⚡ Skipping rate limit for: {request.url.path}")
        return await call_next(request)
    
    # Check rate limit
    is_allowed, error_message = await rate_limiter.check_rate_limit(client_ip)
    
    if not is_allowed:
        headers = rate_limiter.get_rate_limit_headers(client_ip)
        return JSONResponse(
            status_code=429,
            content={
                "detail": error_message,
                "error": "rate_limit_exceeded",
                "retry_after": headers.get("X-RateLimit-Reset", 60)
            },
            headers=headers
        )
    
    # Process request
    response = await call_next(request)
    
    # Add rate limit headers to response
    headers = rate_limiter.get_rate_limit_headers(client_ip)
    for key, value in headers.items():
        response.headers[key] = value
    
    return response
