# Library System API Endpoints

## Base URLs
- **API Gateway**: `http://localhost:8080`
- **Direct Service Access** (if gateway is disabled):
  - Auth Service: `http://localhost:3002`
  - User Service: `http://localhost:3001`
  - Catalog Service: `http://localhost:3003`
  - Booking Service: `http://localhost:3004`
  - Policy Service: `http://localhost:3005`
  - Notification Service: `http://localhost:3006`
  - Analytics Service: `http://localhost:3007`

---

## 1. Authentication Service (`/api/auth`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register a new user | No |
| POST | `/api/auth/login` | Login and get JWT token | No |
| GET | `/api/auth/health` | Health check | No |

---

## 2. User Service (`/api/users`)

### Public Endpoints
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/health` | Health check | No |

### User Management Endpoints
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/users/me` | Get current authenticated user | Yes (X-User-Id header) |
| GET | `/api/users` | Get all users | Yes |
| GET | `/api/users/{id}` | Get user by ID | Yes |
| GET | `/api/users/username/{username}` | Get user by username | Yes |
| GET | `/api/users/{id}/restricted` | Check if user is restricted | Yes |
| POST | `/api/users/{id}/restrict` | Restrict a user (admin only) | Yes |
| POST | `/api/users/{id}/unrestrict` | Unrestrict a user (admin only) | Yes |
| GET | `/api/users/pending` | Get pending users (FACULTY/ADMIN only) | Yes (X-User-Role header) |
| GET | `/api/users/rejected` | Get rejected users (FACULTY/ADMIN only) | Yes (X-User-Role header) |
| POST | `/api/users/{id}/approve` | Approve a user (FACULTY/ADMIN only) | Yes (X-User-Role header) |
| POST | `/api/users/{id}/reject` | Reject a user (FACULTY/ADMIN only) | Yes (X-User-Role header) |
| DELETE | `/api/users/{id}` | Delete a user (admin only) | Yes |

### Internal Endpoints (Inter-service communication)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/users/internal/create` | Create user (called by auth-service) | Internal |
| POST | `/api/users/internal/validate` | Validate credentials (called by auth-service) | Internal |

---

## 3. Catalog Service (`/api/resources`)

| Method | Endpoint | Description | Query Parameters | Auth Required |
|--------|----------|-------------|------------------|---------------|
| POST | `/api/resources` | Create a new resource | - | Yes |
| GET | `/api/resources` | Get all resources | `type`, `floor`, `status`, `search` | Yes |
| GET | `/api/resources/{id}` | Get resource by ID | - | Yes |
| PUT | `/api/resources/{id}` | Update resource | - | Yes |
| DELETE | `/api/resources/{id}` | Delete resource | - | Yes |
| GET | `/api/resources/health` | Health check | - | No |

**Query Parameters for GET `/api/resources`:**
- `type` - Filter by ResourceType (e.g., ROOM, EQUIPMENT)
- `floor` - Filter by floor number
- `status` - Filter by ResourceStatus (e.g., AVAILABLE, OCCUPIED)
- `search` - Search resources by name

---

## 4. Booking Service (`/api/bookings`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/bookings` | Create a new booking | Yes (X-User-Id header) |
| GET | `/api/bookings` | Get all bookings | Yes |
| GET | `/api/bookings/{id}` | Get booking by ID | Yes |
| GET | `/api/bookings/user/{userId}` | Get bookings by user ID | Yes |
| GET | `/api/bookings/resource/{resourceId}` | Get bookings by resource ID | Yes |
| PUT | `/api/bookings/{id}` | Update booking | Yes (X-User-Id header) |
| DELETE | `/api/bookings/{id}` | Cancel booking | Yes (X-User-Id header) |
| POST | `/api/bookings/checkin` | Check-in to booking (QR code) | Yes |
| GET | `/api/bookings/health` | Health check | No |

---

## 5. Policy Service (`/api/policies`)

| Method | Endpoint | Description | Query Parameters | Auth Required |
|--------|----------|-------------|------------------|---------------|
| POST | `/api/policies` | Create a new policy | - | Yes |
| GET | `/api/policies` | Get all policies | `active` (boolean) | Yes |
| GET | `/api/policies/{id}` | Get policy by ID | - | Yes |
| PUT | `/api/policies/{id}` | Update policy | - | Yes |
| DELETE | `/api/policies/{id}` | Delete policy | - | Yes |
| POST | `/api/policies/validate` | Validate booking request against policies | - | Yes |
| GET | `/api/policies/health` | Health check | - | No |

**Query Parameters for GET `/api/policies`:**
- `active` - Filter by active status (true/false)

---

## 6. Notification Service (`/api/notifications`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/notifications/user/{userId}` | Get notifications by user ID | Yes |
| GET | `/api/notifications/user/{userId}/unread` | Get unread notifications by user ID | Yes |
| GET | `/api/notifications/user/{userId}/unread/count` | Get unread notification count | Yes |
| PUT | `/api/notifications/{id}/read` | Mark notification as read | Yes |
| PUT | `/api/notifications/user/{userId}/read-all` | Mark all notifications as read | Yes |
| GET | `/api/notifications/health` | Health check | No |

---

## 7. Analytics Service (`/api/analytics`)

| Method | Endpoint | Description | Query Parameters | Auth Required |
|--------|----------|-------------|------------------|---------------|
| GET | `/api/analytics/utilization` | Get utilization statistics | `startDate`, `endDate`, `resourceId` (optional) | Yes |
| GET | `/api/analytics/peak-hours` | Get peak hours | `startTime`, `endTime` | Yes |
| GET | `/api/analytics/overall` | Get overall statistics | `startTime`, `endTime` | Yes |
| GET | `/api/analytics/health` | Health check | - | No |

**Query Parameters:**
- `utilization`: `startDate` (YYYY-MM-DD), `endDate` (YYYY-MM-DD), `resourceId` (optional Long)
- `peak-hours`: `startTime` (YYYY-MM-DDTHH:mm:ss), `endTime` (YYYY-MM-DDTHH:mm:ss)
- `overall`: `startTime` (YYYY-MM-DDTHH:mm:ss), `endTime` (YYYY-MM-DDTHH:mm:ss)

---

## Summary by HTTP Method

### GET Endpoints
- `/api/health` (User Service)
- `/api/auth/health`
- `/api/users/me`
- `/api/users`
- `/api/users/{id}`
- `/api/users/username/{username}`
- `/api/users/{id}/restricted`
- `/api/users/pending`
- `/api/users/rejected`
- `/api/resources`
- `/api/resources/{id}`
- `/api/resources/health`
- `/api/bookings`
- `/api/bookings/{id}`
- `/api/bookings/user/{userId}`
- `/api/bookings/resource/{resourceId}`
- `/api/bookings/health`
- `/api/policies`
- `/api/policies/{id}`
- `/api/policies/health`
- `/api/notifications/user/{userId}`
- `/api/notifications/user/{userId}/unread`
- `/api/notifications/user/{userId}/unread/count`
- `/api/notifications/health`
- `/api/analytics/utilization`
- `/api/analytics/peak-hours`
- `/api/analytics/overall`
- `/api/analytics/health`

### POST Endpoints
- `/api/auth/register`
- `/api/auth/login`
- `/api/users/{id}/restrict`
- `/api/users/{id}/unrestrict`
- `/api/users/{id}/approve`
- `/api/users/{id}/reject`
- `/api/users/internal/create`
- `/api/users/internal/validate`
- `/api/resources`
- `/api/bookings`
- `/api/bookings/checkin`
- `/api/policies`
- `/api/policies/validate`

### PUT Endpoints
- `/api/resources/{id}`
- `/api/bookings/{id}`
- `/api/policies/{id}`
- `/api/notifications/{id}/read`
- `/api/notifications/user/{userId}/read-all`

### DELETE Endpoints
- `/api/users/{id}`
- `/api/resources/{id}`
- `/api/bookings/{id}`
- `/api/policies/{id}`

---

## Authentication Notes

- Currently uses `X-User-Id` header for authentication (instead of JWT tokens in some endpoints)
- Health check endpoints are public (no authentication required)
- Internal endpoints (`/api/users/internal/*`) are for inter-service communication
- Most endpoints require authentication via `X-User-Id` header or JWT token (when implemented)

---

## Total Endpoint Count

- **GET**: 28 endpoints
- **POST**: 14 endpoints
- **PUT**: 5 endpoints
- **DELETE**: 4 endpoints
- **Total**: 49 API endpoints

---

*Last Updated: December 2025*

