# Socoto Database Schema

## Overview
This document describes the complete database schema for the Socoto hyper-local social network platform.

## Core Tables

### 1. profiles
Extends Supabase auth.users with additional user information.

```sql
- id (uuid, PK, FK to auth.users)
- user_type (enum: 'user', 'business_owner', 'admin')
- full_name (text)
- avatar_url (text)
- bio (text)
- phone (text)
- location_lat (decimal)
- location_lng (decimal)
- address (text)
- city (text)
- state (text)
- zip_code (text)
- created_at (timestamptz)
- updated_at (timestamptz)
```

### 2. businesses
Business profiles for local businesses.

```sql
- id (uuid, PK)
- owner_id (uuid, FK to profiles.id)
- name (text, required)
- description (text)
- category_id (uuid, FK to categories.id)
- logo_url (text)
- cover_image_url (text)
- phone (text)
- email (text)
- website (text)
- location_lat (decimal, required)
- location_lng (decimal, required)
- address (text, required)
- city (text, required)
- state (text, required)
- zip_code (text, required)
- hours_json (jsonb) -- Operating hours
- is_verified (boolean, default: false)
- is_active (boolean, default: true)
- rating_average (decimal, default: 0)
- rating_count (integer, default: 0)
- created_at (timestamptz)
- updated_at (timestamptz)
```

### 3. categories
Business categories for classification and filtering.

```sql
- id (uuid, PK)
- name (text, unique, required)
- slug (text, unique, required)
- icon (text)
- description (text)
- parent_id (uuid, FK to categories.id, nullable)
- created_at (timestamptz)
```

### 4. posts
Social feed posts from businesses and users.

```sql
- id (uuid, PK)
- author_id (uuid, FK to profiles.id)
- business_id (uuid, FK to businesses.id, nullable)
- content (text, required)
- media_urls (jsonb) -- Array of S3 URLs
- post_type (enum: 'text', 'image', 'video', 'announcement', 'campaign')
- is_pinned (boolean, default: false)
- likes_count (integer, default: 0)
- comments_count (integer, default: 0)
- shares_count (integer, default: 0)
- created_at (timestamptz)
- updated_at (timestamptz)
```

### 5. post_likes
Track post likes from users.

```sql
- id (uuid, PK)
- post_id (uuid, FK to posts.id)
- user_id (uuid, FK to profiles.id)
- created_at (timestamptz)
- UNIQUE(post_id, user_id)
```

### 6. comments
Comments on posts.

```sql
- id (uuid, PK)
- post_id (uuid, FK to posts.id)
- author_id (uuid, FK to profiles.id)
- content (text, required)
- parent_comment_id (uuid, FK to comments.id, nullable)
- likes_count (integer, default: 0)
- created_at (timestamptz)
- updated_at (timestamptz)
```

### 7. reviews
Business reviews and ratings.

```sql
- id (uuid, PK)
- business_id (uuid, FK to businesses.id)
- reviewer_id (uuid, FK to profiles.id)
- rating (integer, 1-5, required)
- title (text)
- content (text)
- photos (jsonb) -- Array of photo URLs
- is_verified_purchase (boolean, default: false)
- helpful_count (integer, default: 0)
- response_text (text, nullable) -- Business owner response
- response_at (timestamptz, nullable)
- created_at (timestamptz)
- updated_at (timestamptz)
- UNIQUE(business_id, reviewer_id) -- One review per user per business
```

### 8. review_helpful
Track helpful votes on reviews.

```sql
- id (uuid, PK)
- review_id (uuid, FK to reviews.id)
- user_id (uuid, FK to profiles.id)
- created_at (timestamptz)
- UNIQUE(review_id, user_id)
```

### 9. bookings
Appointment bookings between users and businesses.

```sql
- id (uuid, PK)
- business_id (uuid, FK to businesses.id)
- customer_id (uuid, FK to profiles.id)
- booking_date (date, required)
- booking_time (time, required)
- duration_minutes (integer, default: 60)
- service_name (text)
- service_description (text)
- status (enum: 'pending', 'confirmed', 'completed', 'cancelled')
- cancellation_reason (text, nullable)
- notes (text)
- reminder_sent (boolean, default: false)
- created_at (timestamptz)
- updated_at (timestamptz)
```

### 10. campaigns
Discount campaigns and promotions.

```sql
- id (uuid, PK)
- business_id (uuid, FK to businesses.id)
- title (text, required)
- description (text)
- discount_type (enum: 'percentage', 'fixed_amount', 'bogo')
- discount_value (decimal)
- code (text, unique, nullable)
- image_url (text)
- start_date (timestamptz, required)
- end_date (timestamptz, required)
- is_active (boolean, default: true)
- view_count (integer, default: 0)
- claim_count (integer, default: 0)
- max_claims (integer, nullable)
- created_at (timestamptz)
- updated_at (timestamptz)
```

### 11. campaign_claims
Track users who claimed campaigns.

```sql
- id (uuid, PK)
- campaign_id (uuid, FK to campaigns.id)
- user_id (uuid, FK to profiles.id)
- claimed_at (timestamptz)
- used_at (timestamptz, nullable)
- UNIQUE(campaign_id, user_id)
```

### 12. conversations
Message conversations between users and businesses.

```sql
- id (uuid, PK)
- participant_1_id (uuid, FK to profiles.id)
- participant_2_id (uuid, FK to profiles.id)
- business_id (uuid, FK to businesses.id, nullable)
- last_message_at (timestamptz)
- created_at (timestamptz)
- updated_at (timestamptz)
- UNIQUE(participant_1_id, participant_2_id, business_id)
```

### 13. messages
Individual messages in conversations.

```sql
- id (uuid, PK)
- conversation_id (uuid, FK to conversations.id)
- sender_id (uuid, FK to profiles.id)
- content (text)
- attachment_url (text, nullable)
- attachment_type (enum: 'image', 'video', 'document', nullable)
- is_read (boolean, default: false)
- read_at (timestamptz, nullable)
- created_at (timestamptz)
```

### 14. follows
Track user-business follow relationships.

```sql
- id (uuid, PK)
- follower_id (uuid, FK to profiles.id)
- business_id (uuid, FK to businesses.id)
- created_at (timestamptz)
- UNIQUE(follower_id, business_id)
```

### 15. subscriptions
Stripe subscription tracking for premium businesses.

```sql
- id (uuid, PK)
- business_id (uuid, FK to businesses.id, unique)
- stripe_subscription_id (text, unique)
- stripe_customer_id (text)
- status (enum: 'active', 'past_due', 'canceled', 'incomplete')
- current_period_start (timestamptz)
- current_period_end (timestamptz)
- cancel_at_period_end (boolean, default: false)
- created_at (timestamptz)
- updated_at (timestamptz)
```

### 16. notifications
User notifications for various events.

```sql
- id (uuid, PK)
- user_id (uuid, FK to profiles.id)
- type (enum: 'booking', 'message', 'review', 'campaign', 'follow', 'system')
- title (text, required)
- message (text)
- data (jsonb) -- Additional context
- is_read (boolean, default: false)
- read_at (timestamptz, nullable)
- action_url (text, nullable)
- created_at (timestamptz)
```

### 17. reports
Content moderation and user reports.

```sql
- id (uuid, PK)
- reporter_id (uuid, FK to profiles.id)
- reported_user_id (uuid, FK to profiles.id, nullable)
- reported_business_id (uuid, FK to businesses.id, nullable)
- reported_post_id (uuid, FK to posts.id, nullable)
- reported_review_id (uuid, FK to reviews.id, nullable)
- reason (enum: 'spam', 'inappropriate', 'harassment', 'fake', 'other')
- description (text)
- status (enum: 'pending', 'reviewing', 'resolved', 'dismissed')
- resolved_by (uuid, FK to profiles.id, nullable)
- resolved_at (timestamptz, nullable)
- resolution_notes (text, nullable)
- created_at (timestamptz)
```

## Indexes

```sql
-- Profile lookups
CREATE INDEX idx_profiles_user_type ON profiles(user_type);
CREATE INDEX idx_profiles_location ON profiles USING GIST (point(location_lng, location_lat));

-- Business searches
CREATE INDEX idx_businesses_category ON businesses(category_id);
CREATE INDEX idx_businesses_owner ON businesses(owner_id);
CREATE INDEX idx_businesses_location ON businesses USING GIST (point(location_lng, location_lat));
CREATE INDEX idx_businesses_rating ON businesses(rating_average DESC);
CREATE INDEX idx_businesses_active ON businesses(is_active) WHERE is_active = true;

-- Posts feed
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_business ON posts(business_id);
CREATE INDEX idx_posts_created ON posts(created_at DESC);

-- Reviews
CREATE INDEX idx_reviews_business ON reviews(business_id);
CREATE INDEX idx_reviews_reviewer ON reviews(reviewer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Bookings
CREATE INDEX idx_bookings_business ON bookings(business_id);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_date ON bookings(booking_date, booking_time);
CREATE INDEX idx_bookings_status ON bookings(status);

-- Campaigns
CREATE INDEX idx_campaigns_business ON campaigns(business_id);
CREATE INDEX idx_campaigns_active ON campaigns(is_active, end_date) WHERE is_active = true;

-- Messages
CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_unread ON messages(conversation_id) WHERE is_read = false;

-- Notifications
CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(user_id) WHERE is_read = false;
```

## Row Level Security (RLS) Policies

All tables will have RLS enabled with appropriate policies for:
- Users can read their own data
- Users can update their own profiles
- Businesses can manage their own content
- Public read access for business profiles and posts
- Private access for messages and bookings
- Admin access for moderation
