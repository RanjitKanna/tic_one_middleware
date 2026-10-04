# TIC-ONE API Documentation & Frontend Integration Guide

This document outlines all available endpoints, request/response models, and headers to connect your Web or Mobile frontend with the **`tic_one_middleware`** backend.

---

## 1. Base Configuration

* **Local Base URL**: `http://localhost:8080` (or `http://10.0.2.2:8080` for Android Emulator)
* **Content-Type**: `application/json`
* **Authentication Scheme**: Bearer Token (`Authorization: Bearer <accessToken>`)

---

## 2. Authentication APIs

### 2.1 Register User
* **Endpoint**: `POST /auth/register`
* **Auth**: None

#### Request Body
```json
{
  "name": "John Doe",
  "email": "johndoe@example.com",
  "phone": "9876543210",
  "password": "Password123!"
}
```

#### Success Response (`201 Created`)
```json
{
  "message": "Registration successful",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "johndoe@example.com",
    "phone": "9876543210",
    "createdAt": "2026-10-01 11:30:00.000000"
  }
}
```

---

### 2.2 Login User
* **Endpoint**: `POST /auth/login`
* **Auth**: None

#### Request Body (Accepts Email or Phone)
```json
{
  "identifier": "johndoe@example.com",
  "password": "Password123!"
}
```

#### Success Response (`200 OK`)
```json
{
  "message": "Login successful",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "48b6f3b0-...",
  "expiresIn": 900,
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "johndoe@example.com",
    "phone": "9876543210"
  }
}
```

---

### 2.3 Refresh Token
* **Endpoint**: `POST /auth/refresh-token`
* **Auth**: None

#### Request Body
```json
{
  "refreshToken": "<your-refresh-token>"
}
```

#### Success Response (`200 OK`)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 900
}
```

---

### 2.4 User Profile
* **Endpoint**: `GET /auth/profile`
* **Auth**: `Bearer <accessToken>`

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "johndoe@example.com",
    "phone": "9876543210"
  }
}
```

---

## 3. Home Feed API

### 3.1 Get Home Feed
* **Endpoint**: `GET /home`
* **Query Parameters**:
  * `city` *(optional, default: `Downtown`)* — e.g. `Downtown`, `Mumbai`, `Bengaluru`
  * `language` *(optional, default: `All`)* — e.g. `English`, `Hindi`, `Tamil`
* **Auth**: None

#### Example Request
`GET /home?city=Downtown&language=English`

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "data": {
    "location": {
      "popularCities": [
        "Downtown",
        "Mumbai",
        "Bengaluru",
        "Delhi-NCR",
        "Chennai",
        "Hyderabad"
      ]
    },
    "languages": ["All", "English", "Hindi", "Tamil", "Telugu", "Malayalam", "Kannada"],
    "heroCarousel": [
      {
        "id": "BAN_001",
        "movieId": "MOV_CYBER_2026",
        "slug": "cyberpunk-odyssey-2026",
        "title": "CYBERPUNK: ODYSSEY",
        "subtitle": "Sci-Fi • 2h 48m • Rated R • Directed by Denis Villeneuve",
        "imageUrl": "https://...",
        "rating": 9.6,
        "ratingCount": "120K",
        "format": "IMAX 70MM",
        "isTrending": true
      }
    ],
    "nowShowingMovies": [
      {
        "id": "mov_ns_1",
        "movieId": "MOV_CYBER_2026",
        "slug": "cyberpunk-odyssey-2026",
        "title": "CYBERPUNK: ODYSSEY",
        "genre": "Sci-Fi / Action",
        "imageUrl": "https://...",
        "rating": 9.6,
        "badgeText": "Trending #1",
        "matchPercent": "99% Match",
        "isFillingFast": true,
        "language": "English"
      }
    ],
    "upcomingMovies": [
      {
        "id": "mov_up_5",
        "movieId": "MOV_AVATAR3_2026",
        "slug": "avatar-fire-and-ash",
        "title": "AVATAR: FIRE & ASH",
        "genre": "Sci-Fi • Adventure",
        "imageUrl": "https://...",
        "releaseDate": "Dec 19",
        "certificate": "UA16+",
        "isAdvanceBookingOpen": true
      }
    ],
    "nearbyTheaters": [
      {
        "id": "TH_001",
        "name": "Grand IMAX Dolby Suite",
        "distance": "1.8 km away • Forum Mall",
        "format": "IMAX 70mm Laser 3D, Dolby Atmos",
        "showtimes": ["01:15 PM", "04:30 PM", "08:00 PM", "10:45 PM"],
        "isFastFilling": true
      }
    ],
    "trailers": [
      {
        "id": "TRL_001",
        "title": "Filming the Dune Orbital Sequence in IMAX 70mm",
        "subtitle": "Director commentary • 450K views",
        "imageUrl": "https://...",
        "videoUrl": "https://www.youtube.com/watch?v=sample1",
        "duration": "02:45",
        "tagLabel": "BTS Special"
      }
    ]
  }
}
```

---

## 4. Movies & Shows APIs

### 4.1 Search & List Movies
* **Endpoint**: `GET /movies`
* **Query Parameters**:
  * `status` *(optional)*: `now_showing` | `upcoming`
  * `genre` *(optional)*: e.g. `Sci-Fi`, `Action`
  * `language` *(optional)*: e.g. `English`, `Hindi`
  * `q` *(optional)*: Search text

---

### 4.2 Movie Details
* **Endpoint**: `GET /movies/:slug` *(Accepts slug or movie code)*
* **Example**: `GET /movies/cyberpunk-odyssey-2026`

---

### 4.3 Get Theaters & Shows for Movie
* **Endpoint**: `GET /movies/:movieId/shows`
* **Query Parameters**:
  * `city` *(optional, default: `Downtown`)*
  * `date` *(optional, format: `YYYY-MM-DD`)*
* **Example**: `GET /movies/MOV_CYBER_2026/shows?city=Downtown`

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "data": {
    "movie": {
      "id": 1,
      "movieCode": "MOV_CYBER_2026",
      "title": "CYBERPUNK: ODYSSEY",
      "format": "IMAX 70MM",
      "durationMins": 168,
      "certificate": "Rated R"
    },
    "city": "Downtown",
    "theaters": [
      {
        "theaterId": 1,
        "theaterCode": "TH_001",
        "name": "Grand IMAX Dolby Suite",
        "distance": "1.8 km away • Forum Mall",
        "landmark": "Forum Mall, 4th Floor",
        "address": "100 Feet Road, Downtown Core",
        "shows": [
          {
            "showId": 1,
            "screenId": 1,
            "screenName": "Audi 1 - IMAX 70mm",
            "showTime": "2026-10-01T13:45:00.000Z",
            "timeFormatted": "01:15 PM",
            "language": "English",
            "format": "IMAX 70MM",
            "basePrice": 350.0,
            "status": "active",
            "isFastFilling": true
          }
        ]
      }
    ]
  }
}
```

---

## 5. Seat Matrix & Concurrency Locking

### 5.1 Get Seat Layout & Live Availability
* **Endpoint**: `GET /shows/:showId/seats`
* **Example**: `GET /shows/1/seats`

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "data": {
    "show": {
      "id": 1,
      "movieTitle": "CYBERPUNK: ODYSSEY",
      "theaterName": "Grand IMAX Dolby Suite",
      "screenName": "Audi 1 - IMAX 70mm",
      "timeFormatted": "01:15 PM",
      "basePrice": 350.0
    },
    "tiers": [
      { "tierName": "Silver", "price": 350.0 },
      { "tierName": "Gold", "price": 438.0 },
      { "tierName": "Platinum Recliner", "price": 560.0 }
    ],
    "rows": [
      {
        "rowLabel": "A",
        "seats": [
          {
            "seatId": 1,
            "row": "A",
            "number": 1,
            "identifier": "A1",
            "tier": "Silver",
            "price": 350.0,
            "status": "available" // "available" | "locked" | "booked"
          }
        ]
      }
    ]
  }
}
```

---

### 5.2 Lock Selected Seats (8 Minutes Hold)
* **Endpoint**: `POST /shows/:showId/lock-seats`
* **Auth**: Optional Bearer token

#### Request Body
```json
{
  "seatIdentifiers": ["C3", "C4"]
}
```

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "message": "Seats locked for 8 minutes",
  "data": {
    "lockToken": "LOCK_1790835663431_333813",
    "expiresAt": "2026-10-01T11:59:03.431Z",
    "expiresInSeconds": 480,
    "lockedSeats": [
      { "seatId": 27, "identifier": "C3", "tier": "Gold", "price": 438.0 },
      { "seatId": 28, "identifier": "C4", "tier": "Gold", "price": 438.0 }
    ],
    "pricing": {
      "ticketCount": 2,
      "subtotal": 876.0,
      "convenienceFee": 35.40,
      "totalAmount": 911.40
    }
  }
}
```

---

## 6. Bookings & Ticket APIs

### 6.1 Create & Confirm Booking
* **Endpoint**: `POST /bookings/create`
* **Auth**: `Bearer <accessToken>` (Required)

#### Request Body
```json
{
  "showId": 1,
  "lockToken": "LOCK_1790835663431_333813"
}
```

#### Success Response (`201 Created`)
```json
{
  "status": "success",
  "message": "Booking confirmed successfully!",
  "data": {
    "bookingId": 1,
    "bookingCode": "TIC-2026-216175",
    "bookingStatus": "confirmed",
    "paymentStatus": "completed",
    "createdAt": "2026-10-01T11:51:04.000Z",
    "movie": {
      "title": "CYBERPUNK: ODYSSEY",
      "imageUrl": "https://...",
      "format": "IMAX 70MM",
      "language": "English"
    },
    "theater": {
      "name": "Grand IMAX Dolby Suite",
      "address": "100 Feet Road, Downtown Core",
      "screen": "Audi 1 - IMAX 70mm"
    },
    "showTime": "2026-10-01T13:45:00.000Z",
    "timeFormatted": "01:15 PM",
    "seats": [
      { "seatId": 27, "identifier": "C3", "tier": "Gold", "price": 438.0 },
      { "seatId": 28, "identifier": "C4", "tier": "Gold", "price": 438.0 }
    ],
    "pricing": {
      "ticketCount": 2,
      "subtotal": 876.0,
      "convenienceFee": 35.40,
      "totalAmount": 911.40
    },
    "qrCodeData": "eyJjb2RlIjoiVElDLTIwMjYtMjE2MTc1Iiwic2hvd0lkIjoxLCJ1c2VySWQiOjEsInNlYXRzIjpbIkMzIiwiQzQiXX0="
  }
}
```

---

### 6.2 Get User Booking History (My Tickets)
* **Endpoint**: `GET /bookings/my-tickets`
* **Auth**: `Bearer <accessToken>` (Required)

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "count": 1,
  "data": [
    {
      "id": 1,
      "bookingCode": "TIC-2026-216175",
      "totalSeats": 2,
      "totalAmount": 911.40,
      "paymentStatus": "completed",
      "bookingStatus": "confirmed",
      "movie": {
        "title": "CYBERPUNK: ODYSSEY",
        "posterUrl": "https://...",
        "certificate": "Rated R"
      },
      "theater": {
        "name": "Grand IMAX Dolby Suite",
        "address": "100 Feet Road, Downtown Core",
        "screen": "Audi 1 - IMAX 70mm"
      },
      "showTime": "2026-10-01T13:45:00.000Z",
      "timeFormatted": "01:15 PM",
      "format": "IMAX 70MM",
      "language": "English",
      "seats": ["C3", "C4"],
      "qrCodeData": "..."
    }
  ]
}
```

---

### 6.3 Get Single Ticket by Booking Code
* **Endpoint**: `GET /bookings/:bookingCode`
* **Example**: `GET /bookings/TIC-2026-216175`
* **Auth**: None (Public digital ticket lookup for gate scanning)

---

### 6.4 Cancel Ticket Booking
* **Endpoint**: `POST /bookings/:bookingCode/cancel` (or `POST /bookings/cancel`)
* **Auth**: None / Optional Bearer Token

#### Request Body
```json
{
  "bookingCode": "TIC-2026-216175",
  "reason": "Change of plans"
}
```

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "message": "Booking TIC-2026-216175 cancelled successfully. Refund of ₹911.40 initiated.",
  "data": {
    "bookingId": 1,
    "bookingCode": "TIC-2026-216175",
    "bookingStatus": "cancelled",
    "paymentStatus": "refunded",
    "refundAmount": 911.40,
    "refundStatus": "initiated",
    "cancelledAt": "2026-10-04T08:15:00.000Z"
  }
}
```

---

### 6.5 Get Cancelled Tickets
* **Endpoint**: `GET /bookings/cancelled` (or `GET /bookings/my-tickets?status=cancelled`)
* **Auth**: `Bearer <accessToken>` (Required)

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "filter": "cancelled",
  "count": 1,
  "data": [
    {
      "id": 1,
      "bookingCode": "TIC-2026-216175",
      "totalSeats": 2,
      "ticketAmount": 876.0,
      "convenienceFee": 35.40,
      "totalAmount": 911.40,
      "paymentStatus": "refunded",
      "bookingStatus": "cancelled",
      "statusCategory": "cancelled",
      "movie": {
        "title": "CYBERPUNK: ODYSSEY",
        "posterUrl": "https://...",
        "certificate": "Rated R"
      },
      "theater": {
        "name": "Grand IMAX Dolby Suite",
        "address": "100 Feet Road, Downtown Core",
        "screen": "Audi 1 - IMAX 70mm"
      },
      "showTime": "2026-10-01T13:45:00.000Z",
      "timeFormatted": "01:15 PM",
      "format": "IMAX 70MM",
      "language": "English",
      "seats": ["C3", "C4"]
    }
  ]
}
```

---

### 6.6 Get Past / Completed Tickets
* **Endpoint**: `GET /bookings/past` (or `GET /bookings/my-tickets?status=past`)
* **Auth**: `Bearer <accessToken>` (Required)

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "filter": "past",
  "count": 1,
  "data": [
    {
      "id": 2,
      "bookingCode": "TIC-2026-104928",
      "totalSeats": 1,
      "ticketAmount": 438.0,
      "convenienceFee": 35.40,
      "totalAmount": 473.40,
      "paymentStatus": "completed",
      "bookingStatus": "completed",
      "statusCategory": "past",
      "movie": {
        "title": "AVATAR: FIRE & ASH",
        "posterUrl": "https://...",
        "certificate": "UA16+"
      },
      "theater": {
        "name": "Grand IMAX Dolby Suite",
        "address": "100 Feet Road, Downtown Core",
        "screen": "Audi 1 - IMAX 70mm"
      },
      "showTime": "2026-09-20T18:30:00.000Z",
      "timeFormatted": "06:30 PM",
      "format": "IMAX 3D",
      "language": "English",
      "seats": ["E12"]
    }
  ]
}
```
