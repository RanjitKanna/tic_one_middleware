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
      "currentCity": "Downtown",
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
* **Auth**: `Bearer <accessToken>` (Optional / Required depending on scope)

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
    "bookingCode": "TIC-2026-216175",
    "bookingStatus": "cancelled",
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



---

## 7. Bus Booking APIs

The Bus Booking module shares the exact same JWT authentication and user profile system with the Movie Booking system (`/auth/login`, `/auth/register`, `/auth/profile`).

---

### 7.1 Search & List Available Buses
* **Endpoint**: `GET /buses/search`
* **Query Parameters**:
  * `source` *(required or optional)* — Departure city (e.g. `Bengaluru`)
  * `destination` *(required or optional)* — Arrival city (e.g. `Chennai`)
  * `date` *(optional, format: `YYYY-MM-DD`)* — Travel date (defaults to today & onward)
  * `busType` *(optional)* — `AC` | `Non-AC` | `Sleeper` | `Seater` | `Semi-Sleeper`
  * `operatorId` *(optional)* — Filter by specific bus operator ID
  * `minPrice` / `maxPrice` *(optional)* — Price range filters
  * `sortBy` *(optional)* — `price_asc` | `price_desc` | `rating` | `duration` | `departure_asc`

#### Example Request
`GET /buses/search?source=Bengaluru&destination=Chennai&busType=sleeper`

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "message": "Available buses fetched successfully",
  "searchParams": {
    "source": "Bengaluru",
    "destination": "Chennai",
    "travelDate": null,
    "busType": "sleeper",
    "sortBy": "departure_asc"
  },
  "totalAvailableBuses": 45,
  "data": [
    {
      "tripId": 1,
      "tripCode": "TRIP-RT-BLR-CHE-20261005-01",
      "travelDate": "2026-10-05",
      "departureTime": "2026-10-05T22:30:00.000Z",
      "arrivalTime": "2026-10-06T04:30:00.000Z",
      "departureTimeFormatted": "10:30 PM",
      "arrivalTimeFormatted": "04:30 AM",
      "durationFormatted": "6h 00m",
      "baseFare": 950.0,
      "startingPrice": 950.0,
      "tripStatus": "active",
      "bus": {
        "id": 1,
        "busCode": "BUS-INTR-VOLVO9600",
        "busName": "IntrCity SmartBus Volvo 9600 AC Sleeper (2+1)",
        "busNumber": "KA-01-AJ-4001",
        "busType": "Volvo 9600 Multi-Axle AC Sleeper (2+1)",
        "category": "sleeper",
        "isAc": true,
        "deckType": "double",
        "totalSeats": 36,
        "availableSeats": 34,
        "bookedSeats": 2,
        "lockedSeats": 0,
        "amenities": ["WiFi", "Live Tracking", "Charging Point", "Water Bottle", "Sanitized Blanket", "Reading Light", "Emergency Exit", "CCTV", "Washroom"],
        "liveTrackingAvailable": true
      },
      "operator": {
        "id": 1,
        "operatorCode": "OP-INTRCITY",
        "name": "IntrCity SmartBus",
        "logoUrl": "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957...",
        "rating": 4.8,
        "totalReviews": 14250,
        "contactNumber": "+91 80 4710 8888"
      },
      "route": {
        "id": 1,
        "routeCode": "RT-BLR-CHE",
        "sourceCity": "Bengaluru",
        "destinationCity": "Chennai",
        "distanceKm": 350.0,
        "estimatedDurationMins": 360
      },
      "boardingPointsCount": 6,
      "droppingPointsCount": 6
    }
  ]
}
```

---

### 7.2 Popular Cities & Routes
* **Endpoint**: `GET /buses/cities` or `GET /buses/routes`
* **Auth**: None

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "data": {
    "cities": ["Bengaluru", "Chennai", "Coimbatore", "Delhi", "Goa", "Hyderabad", "Jaipur", "Mumbai", "Pune", "Vijayawada"],
    "popularRoutes": [
      {
        "id": 1,
        "routeCode": "RT-BLR-CHE",
        "sourceCity": "Bengaluru",
        "destinationCity": "Chennai",
        "distanceKm": 350.0,
        "estimatedDurationMins": 360,
        "isPopular": true,
        "startingFare": 550.0,
        "dailyTripsCount": 4
      }
    ],
    "operators": [ ... ],
    "busTypes": [
      { "label": "All Types", "value": "all" },
      { "label": "AC Sleeper (2+1)", "value": "sleeper" },
      { "label": "AC Semi-Sleeper (2+2)", "value": "semi_sleeper" },
      { "label": "AC Seater (2+2)", "value": "seater" },
      { "label": "Volvo Multi-Axle AC", "value": "volvo" },
      { "label": "Non-AC Sleeper", "value": "non-ac" }
    ]
  }
}
```

---

### 7.3 Bus & Trip Details
* **Endpoint**: `GET /buses/:busId` (Accepts `busId`, `tripId`, `busCode`, or `tripCode`)
* **Auth**: None

---

### 7.4 Bus Seat Matrix & Live Layout
* **Endpoint**: `GET /buses/:busId/seats`
* **Auth**: None

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "data": {
    "trip": {
      "tripId": 1,
      "tripCode": "TRIP-RT-BLR-CHE-20261005-01",
      "busId": 1,
      "busName": "IntrCity SmartBus Volvo 9600 AC Sleeper (2+1)",
      "busType": "Volvo 9600 Multi-Axle AC Sleeper (2+1)",
      "category": "sleeper",
      "operatorName": "IntrCity SmartBus",
      "sourceCity": "Bengaluru",
      "destinationCity": "Chennai",
      "travelDate": "2026-10-05",
      "departureTimeFormatted": "10:30 PM",
      "arrivalTimeFormatted": "04:30 AM",
      "durationFormatted": "6h 00m",
      "baseFare": 950.0
    },
    "summary": {
      "totalSeats": 36,
      "availableSeats": 34,
      "bookedSeats": 2,
      "lockedSeats": 0,
      "deckType": "double",
      "startingPrice": 950.0
    },
    "tiers": [
      { "tierName": "Premium Berth", "price": 1093.0, "multiplier": 1.15 },
      { "tierName": "Standard", "price": 950.0, "multiplier": 1.0 }
    ],
    "layout": {
      "hasUpperDeck": true,
      "lowerDeck": [
        {
          "seatId": 1,
          "seatNumber": "L1",
          "deck": "lower",
          "row": 1,
          "column": 1,
          "seatType": "sleeper",
          "berthType": "single_berth",
          "isWindow": true,
          "isAisle": false,
          "genderPreference": "ladies_only",
          "seatTier": "Premium Berth",
          "price": 1093.0,
          "status": "available",
          "bookedGender": "ladies_only"
        }
      ],
      "upperDeck": [ ... ]
    }
  }
}
```

---

### 7.5 Boarding & Dropping Points
* **Endpoints**: 
  * `GET /buses/:busId/boarding-points`
  * `GET /buses/:busId/dropping-points`
* **Auth**: None

---

### 7.6 AI-Based Recommended Seat Selection
* **Endpoint**: `GET /buses/:busId/recommend-seats?passengers=2&preference=comfort` (or `POST /buses/recommend-seats`)
* **Query / Body Parameters**:
  * `passengers` *(default: 1)* — Number of passengers (1-6)
  * `preference` *(optional)* — `comfort` | `solo` | `couple_pair` | `female_safety` | `quick_exit` | `best_value`
  * `gender` *(optional)* — `female` | `male` | `any`

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "message": "AI-driven seat recommendations generated",
  "tripId": 1,
  "passengerCount": 2,
  "requestedPreference": "comfort",
  "totalAvailableSeatsCount": 34,
  "data": {
    "topPick": {
      "recommendationType": "top_comfort",
      "badge": "AI Pick • Top Comfort & Smooth Ride",
      "score": 98,
      "reason": "Lower deck middle section minimizes road vibrations and axle jolts, giving the smoothest sleep experience with window alignment.",
      "seats": [
        { "seatId": 10, "seatNumber": "L4", "deck": "lower", "tier": "Premium Berth", "price": 1093.0 },
        { "seatId": 11, "seatNumber": "L5", "deck": "lower", "tier": "Standard", "price": 950.0 }
      ],
      "totalFare": 2043.0
    },
    "allRecommendations": [ ... ]
  }
}
```

---

### 7.7 Hold Seats (10-Minute Concurrency Lock)
* **Endpoint**: `POST /bus-bookings/hold-seats`
* **Auth**: Optional Bearer token

#### Request Body
```json
{
  "tripId": 1,
  "seatNumbers": ["L4", "L5"]
}
```

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "message": "Seats successfully locked for 10 minutes",
  "data": {
    "lockToken": "BUS_LOCK_1791129318575_969321",
    "tripId": 1,
    "busName": "IntrCity SmartBus Volvo 9600 AC Sleeper (2+1)",
    "busType": "Volvo 9600 Multi-Axle AC Sleeper (2+1)",
    "expiresAt": "2026-10-04T16:04:18.575Z",
    "expiresInSeconds": 600,
    "seatCount": 2,
    "lockedSeats": [
      { "seatId": 10, "seatNumber": "L4", "deck": "lower", "seatType": "sleeper", "berthType": "single_berth", "tier": "Premium Berth", "price": 1093.0 },
      { "seatId": 11, "seatNumber": "L5", "deck": "lower", "seatType": "sleeper", "berthType": "double_berth", "tier": "Standard", "price": 950.0 }
    ],
    "pricing": {
      "baseFareSubtotal": 2043.0,
      "gstTaxAmount": 102.0,
      "convenienceFee": 25.0,
      "totalAmount": 2170.0
    }
  }
}
```

---

### 7.8 Validate Promo / Coupon Code
* **Endpoint**: `POST /bus-promos/validate`
* **Auth**: None

#### Request Body
```json
{
  "code": "FIRSTBUS",
  "amount": 2043.0
}
```

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "statusCode": 200,
  "isValid": true,
  "message": "Promo code 'FIRSTBUS' applied successfully! You saved ₹200.00.",
  "data": {
    "promoCode": "FIRSTBUS",
    "title": "First Bus Booking Special",
    "discountType": "percentage",
    "discountValue": 15.0,
    "originalAmount": 2043.0,
    "discountAmount": 200.0,
    "finalPayableAmount": 1843.0
  }
}
```

---

### 7.9 Create & Confirm Bus Booking
* **Endpoint**: `POST /bus-bookings`
* **Auth**: `Bearer <accessToken>` (Required)

#### Request Body
```json
{
  "tripId": 1,
  "lockToken": "BUS_LOCK_1791129318575_969321",
  "boardingPointId": 1,
  "droppingPointId": 7,
  "contactEmail": "johndoe@example.com",
  "contactPhone": "9876543210",
  "promoCode": "FIRSTBUS",
  "paymentMethod": "upi",
  "passengers": [
    {
      "name": "John Doe",
      "age": 28,
      "gender": "Male",
      "seatNumber": "L4"
    },
    {
      "name": "Jane Doe",
      "age": 26,
      "gender": "Female",
      "seatNumber": "L5"
    }
  ]
}
```

#### Success Response (`201 Created`)
```json
{
  "status": "success",
  "statusCode": 201,
  "message": "Bus booking confirmed successfully!",
  "data": {
    "bookingId": 2,
    "bookingCode": "TIC-BUS-2026-665141",
    "pnrNumber": "PNR7547575",
    "bookingStatus": "confirmed",
    "paymentStatus": "completed",
    "createdAt": "2026-10-04T15:55:18.000Z",
    "trip": {
      "tripId": 1,
      "tripCode": "TRIP-RT-BLR-CHE-20261005-01",
      "travelDate": "2026-10-05",
      "departureTime": "2026-10-05T22:30:00.000Z",
      "arrivalTime": "2026-10-06T04:30:00.000Z",
      "departureTimeFormatted": "10:30 PM",
      "arrivalTimeFormatted": "04:30 AM",
      "durationFormatted": "6h 00m"
    },
    "bus": {
      "id": 1,
      "name": "IntrCity SmartBus Volvo 9600 AC Sleeper (2+1)",
      "number": "KA-01-AJ-4001",
      "type": "Volvo 9600 Multi-Axle AC Sleeper (2+1)"
    },
    "operator": {
      "name": "IntrCity SmartBus",
      "logoUrl": "https://..."
    },
    "route": {
      "sourceCity": "Bengaluru",
      "destinationCity": "Chennai"
    },
    "boardingPoint": {
      "id": 1,
      "pointName": "Majestic - Anand Rao Circle",
      "landmark": "Near SRS Travels Office",
      "timeFormatted": "10:30 PM"
    },
    "droppingPoint": {
      "id": 7,
      "pointName": "Koyambedu - Omni Bus Stand",
      "landmark": "Platform 6, Omni Bus Stand",
      "timeFormatted": "04:30 AM"
    },
    "seats": [
      { "seatId": 10, "seatNumber": "L4", "deck": "lower", "tier": "Premium Berth", "price": 1093.0 },
      { "seatId": 11, "seatNumber": "L5", "deck": "lower", "tier": "Standard", "price": 950.0 }
    ],
    "passengers": [
      { "name": "John Doe", "age": 28, "gender": "Male", "seatNumber": "L4" },
      { "name": "Jane Doe", "age": 26, "gender": "Female", "seatNumber": "L5" }
    ],
    "pricing": {
      "ticketCount": 2,
      "baseFareSubtotal": 2043.0,
      "gstTaxAmount": 102.0,
      "convenienceFee": 25.0,
      "discountAmount": 200.0,
      "promoCodeApplied": "FIRSTBUS",
      "totalAmount": 1970.0
    },
    "payment": {
      "paymentId": "PAY-BUS-1791129318856",
      "method": "upi",
      "status": "completed"
    },
    "qrCodeData": "eyJjb2RlIjoiVElDLUJVUy0yMDI2LTY2NTE0MSIsInBuciI6IlBOUjc1NDc1NzUiLCJ0cmlwSWQiOjEsInVzZXJJZCI6MSwic2VhdHMiOlsiTDQiLCJMNSJdfQ=="
  }
}
```

---

### 7.10 Get User Bus Bookings (History)
* **Endpoint**: `GET /bus-bookings?status=all|upcoming|completed|cancelled`
* **Auth**: `Bearer <accessToken>` (Required)

---

### 7.11 Get Single Bus Ticket & Booking Details
* **Endpoint**: `GET /bus-bookings/:bookingId` (Accepts `bookingId`, `bookingCode`, or `pnrNumber`)
* **Auth**: Optional / Public digital ticket lookup

---

### 7.12 Cancel Bus Booking & Initiate Refund
* **Endpoint**: `POST /bus-bookings/:bookingId/cancel`
* **Auth**: `Bearer <accessToken>` (Optional / Required)

#### Request Body
```json
{
  "reason": "Change of travel plans"
}
```

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "message": "Booking TIC-BUS-2026-665141 (PNR7547575) cancelled successfully. Refund of ₹1773.00 (90.0%) initiated.",
  "data": {
    "bookingId": 2,
    "bookingCode": "TIC-BUS-2026-665141",
    "pnrNumber": "PNR7547575",
    "bookingStatus": "cancelled",
    "paymentStatus": "refunded",
    "cancellationCode": "CAN-BUS-1791129318882-741",
    "refundId": "REF-BUS-1791129318882",
    "refundPercentage": 90.0,
    "refundAmount": 1773.0,
    "cancellationFee": 197.0,
    "refundStatus": "completed",
    "cancelledAt": "2026-10-04T15:55:18.882Z",
    "reason": "Change of travel plans"
  }
}
```

---

### 7.13 Get Refund Status
* **Endpoint**: `GET /bus-bookings/:bookingId/refund`
* **Auth**: None

---

### 7.14 Bus Payment APIs
* **Create Payment Intent**: `POST /bus-payments/create`
* **Verify Payment**: `POST /bus-payments/verify`
* **Get Payment Receipt**: `GET /bus-payments/:paymentId`

