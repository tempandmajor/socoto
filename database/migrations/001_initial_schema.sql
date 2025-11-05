-- ============================================
-- Socoto Database Schema Migration
-- Initial schema with role-based authentication
-- ============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================
-- ENUMS
-- ============================================

-- User type enum for role-based access
CREATE TYPE user_type AS ENUM ('user', 'business_owner', 'admin');

-- Post types
CREATE TYPE post_type AS ENUM ('text', 'image', 'video', 'announcement', 'campaign');

-- Booking status
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');

-- Discount types for campaigns
CREATE TYPE discount_type AS ENUM ('percentage', 'fixed_amount', 'bogo');

-- Attachment types for messages
CREATE TYPE attachment_type AS ENUM ('image', 'video', 'document');

-- Subscription status
CREATE TYPE subscription_status AS ENUM ('active', 'past_due', 'canceled', 'incomplete');

-- Notification types
CREATE TYPE notification_type AS ENUM ('booking', 'message', 'review', 'campaign', 'follow', 'system');

-- Report reasons
CREATE TYPE report_reason AS ENUM ('spam', 'inappropriate', 'harassment', 'fake', 'other');

-- Report status
CREATE TYPE report_status AS ENUM ('pending', 'reviewing', 'resolved', 'dismissed');

-- ============================================
-- TABLES
-- ============================================

-- Profiles table (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    user_type user_type NOT NULL DEFAULT 'user',
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    phone TEXT,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    icon TEXT,
    description TEXT,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Businesses table
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    logo_url TEXT,
    cover_image_url TEXT,
    phone TEXT,
    email TEXT,
    website TEXT,
    location_lat DECIMAL(10, 8) NOT NULL,
    location_lng DECIMAL(11, 8) NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    hours_json JSONB,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    rating_average DECIMAL(3, 2) DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Posts table
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    media_urls JSONB DEFAULT '[]'::jsonb,
    post_type post_type NOT NULL DEFAULT 'text',
    is_pinned BOOLEAN DEFAULT FALSE,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Post likes table
CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- Comments table
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reviews table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title TEXT,
    content TEXT,
    photos JSONB DEFAULT '[]'::jsonb,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    response_text TEXT,
    response_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(business_id, reviewer_id)
);

-- Review helpful votes table
CREATE TABLE review_helpful (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(review_id, user_id)
);

-- Bookings table
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    service_name TEXT,
    service_description TEXT,
    status booking_status NOT NULL DEFAULT 'pending',
    cancellation_reason TEXT,
    notes TEXT,
    reminder_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Campaigns table
CREATE TABLE campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    discount_type discount_type NOT NULL,
    discount_value DECIMAL(10, 2),
    code TEXT UNIQUE,
    image_url TEXT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    view_count INTEGER DEFAULT 0,
    claim_count INTEGER DEFAULT 0,
    max_claims INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Campaign claims table
CREATE TABLE campaign_claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    claimed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    used_at TIMESTAMPTZ,
    UNIQUE(campaign_id, user_id)
);

-- Conversations table
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    participant_2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(participant_1_id, participant_2_id, business_id)
);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT,
    attachment_url TEXT,
    attachment_type attachment_type,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Follows table
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(follower_id, business_id)
);

-- Subscriptions table
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID UNIQUE NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    stripe_subscription_id TEXT UNIQUE,
    stripe_customer_id TEXT,
    status subscription_status NOT NULL DEFAULT 'incomplete',
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    data JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    action_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reports table
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reported_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    reported_business_id UUID REFERENCES businesses(id) ON DELETE SET NULL,
    reported_post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
    reported_review_id UUID REFERENCES reviews(id) ON DELETE SET NULL,
    reason report_reason NOT NULL,
    description TEXT,
    status report_status NOT NULL DEFAULT 'pending',
    resolved_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    resolved_at TIMESTAMPTZ,
    resolution_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

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

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to automatically create a profile when a user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, user_type)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
        COALESCE((NEW.raw_user_meta_data->>'user_type')::user_type, 'user')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaigns_updated_at BEFORE UPDATE ON campaigns
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_helpful ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PROFILES POLICIES
-- ============================================

-- Anyone can view public profile info
CREATE POLICY "Public profiles are viewable by everyone"
    ON profiles FOR SELECT
    USING (true);

-- Users can insert their own profile (handled by trigger)
CREATE POLICY "Users can insert their own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- ============================================
-- BUSINESSES POLICIES
-- ============================================

-- Anyone can view active businesses
CREATE POLICY "Active businesses are viewable by everyone"
    ON businesses FOR SELECT
    USING (is_active = true OR owner_id = auth.uid());

-- Business owners can create businesses
CREATE POLICY "Business owners can create businesses"
    ON businesses FOR INSERT
    WITH CHECK (
        auth.uid() = owner_id AND
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type IN ('business_owner', 'admin'))
    );

-- Business owners can update their own businesses
CREATE POLICY "Business owners can update their own businesses"
    ON businesses FOR UPDATE
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- Business owners can delete their own businesses
CREATE POLICY "Business owners can delete their own businesses"
    ON businesses FOR DELETE
    USING (auth.uid() = owner_id);

-- ============================================
-- CATEGORIES POLICIES
-- ============================================

-- Anyone can view categories
CREATE POLICY "Categories are viewable by everyone"
    ON categories FOR SELECT
    USING (true);

-- Only admins can modify categories
CREATE POLICY "Only admins can insert categories"
    ON categories FOR INSERT
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'admin')
    );

CREATE POLICY "Only admins can update categories"
    ON categories FOR UPDATE
    USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'admin')
    );

-- ============================================
-- POSTS POLICIES
-- ============================================

-- Anyone can view posts
CREATE POLICY "Posts are viewable by everyone"
    ON posts FOR SELECT
    USING (true);

-- Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts"
    ON posts FOR INSERT
    WITH CHECK (auth.uid() = author_id);

-- Authors can update their own posts
CREATE POLICY "Authors can update their own posts"
    ON posts FOR UPDATE
    USING (auth.uid() = author_id)
    WITH CHECK (auth.uid() = author_id);

-- Authors can delete their own posts
CREATE POLICY "Authors can delete their own posts"
    ON posts FOR DELETE
    USING (auth.uid() = author_id);

-- ============================================
-- POST LIKES POLICIES
-- ============================================

-- Anyone can view post likes
CREATE POLICY "Post likes are viewable by everyone"
    ON post_likes FOR SELECT
    USING (true);

-- Authenticated users can like posts
CREATE POLICY "Authenticated users can like posts"
    ON post_likes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can unlike their own likes
CREATE POLICY "Users can delete their own likes"
    ON post_likes FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- COMMENTS POLICIES
-- ============================================

-- Anyone can view comments
CREATE POLICY "Comments are viewable by everyone"
    ON comments FOR SELECT
    USING (true);

-- Authenticated users can create comments
CREATE POLICY "Authenticated users can create comments"
    ON comments FOR INSERT
    WITH CHECK (auth.uid() = author_id);

-- Authors can update their own comments
CREATE POLICY "Authors can update their own comments"
    ON comments FOR UPDATE
    USING (auth.uid() = author_id);

-- Authors can delete their own comments
CREATE POLICY "Authors can delete their own comments"
    ON comments FOR DELETE
    USING (auth.uid() = author_id);

-- ============================================
-- REVIEWS POLICIES
-- ============================================

-- Anyone can view reviews
CREATE POLICY "Reviews are viewable by everyone"
    ON reviews FOR SELECT
    USING (true);

-- Authenticated users can create reviews
CREATE POLICY "Authenticated users can create reviews"
    ON reviews FOR INSERT
    WITH CHECK (auth.uid() = reviewer_id);

-- Reviewers can update their own reviews
CREATE POLICY "Reviewers can update their own reviews"
    ON reviews FOR UPDATE
    USING (auth.uid() = reviewer_id)
    WITH CHECK (auth.uid() = reviewer_id);

-- Reviewers can delete their own reviews
CREATE POLICY "Reviewers can delete their own reviews"
    ON reviews FOR DELETE
    USING (auth.uid() = reviewer_id);

-- ============================================
-- BOOKINGS POLICIES
-- ============================================

-- Users can view their own bookings as customer or business owner
CREATE POLICY "Users can view their own bookings"
    ON bookings FOR SELECT
    USING (
        auth.uid() = customer_id OR
        auth.uid() IN (SELECT owner_id FROM businesses WHERE id = bookings.business_id)
    );

-- Authenticated users can create bookings
CREATE POLICY "Authenticated users can create bookings"
    ON bookings FOR INSERT
    WITH CHECK (auth.uid() = customer_id);

-- Business owners and customers can update bookings
CREATE POLICY "Business owners and customers can update bookings"
    ON bookings FOR UPDATE
    USING (
        auth.uid() = customer_id OR
        auth.uid() IN (SELECT owner_id FROM businesses WHERE id = bookings.business_id)
    );

-- ============================================
-- CAMPAIGNS POLICIES
-- ============================================

-- Anyone can view active campaigns
CREATE POLICY "Active campaigns are viewable by everyone"
    ON campaigns FOR SELECT
    USING (is_active = true OR business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));

-- Business owners can create campaigns
CREATE POLICY "Business owners can create campaigns"
    ON campaigns FOR INSERT
    WITH CHECK (
        auth.uid() IN (SELECT owner_id FROM businesses WHERE id = campaigns.business_id)
    );

-- Business owners can update their campaigns
CREATE POLICY "Business owners can update their campaigns"
    ON campaigns FOR UPDATE
    USING (
        auth.uid() IN (SELECT owner_id FROM businesses WHERE id = campaigns.business_id)
    );

-- ============================================
-- CAMPAIGN CLAIMS POLICIES
-- ============================================

-- Users can view their own claims
CREATE POLICY "Users can view their own claims"
    ON campaign_claims FOR SELECT
    USING (auth.uid() = user_id);

-- Authenticated users can claim campaigns
CREATE POLICY "Authenticated users can claim campaigns"
    ON campaign_claims FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- MESSAGES POLICIES
-- ============================================

-- Users can view messages in their conversations
CREATE POLICY "Users can view their own messages"
    ON messages FOR SELECT
    USING (
        auth.uid() IN (
            SELECT participant_1_id FROM conversations WHERE id = messages.conversation_id
            UNION
            SELECT participant_2_id FROM conversations WHERE id = messages.conversation_id
        )
    );

-- Users can send messages in their conversations
CREATE POLICY "Users can send messages in their conversations"
    ON messages FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id AND
        auth.uid() IN (
            SELECT participant_1_id FROM conversations WHERE id = messages.conversation_id
            UNION
            SELECT participant_2_id FROM conversations WHERE id = messages.conversation_id
        )
    );

-- Users can update their own messages (for read status)
CREATE POLICY "Users can update message read status"
    ON messages FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT participant_1_id FROM conversations WHERE id = messages.conversation_id
            UNION
            SELECT participant_2_id FROM conversations WHERE id = messages.conversation_id
        )
    );

-- ============================================
-- CONVERSATIONS POLICIES
-- ============================================

-- Users can view their own conversations
CREATE POLICY "Users can view their own conversations"
    ON conversations FOR SELECT
    USING (auth.uid() = participant_1_id OR auth.uid() = participant_2_id);

-- Authenticated users can create conversations
CREATE POLICY "Authenticated users can create conversations"
    ON conversations FOR INSERT
    WITH CHECK (auth.uid() = participant_1_id OR auth.uid() = participant_2_id);

-- ============================================
-- FOLLOWS POLICIES
-- ============================================

-- Anyone can view follows
CREATE POLICY "Follows are viewable by everyone"
    ON follows FOR SELECT
    USING (true);

-- Authenticated users can follow businesses
CREATE POLICY "Authenticated users can follow businesses"
    ON follows FOR INSERT
    WITH CHECK (auth.uid() = follower_id);

-- Users can unfollow businesses
CREATE POLICY "Users can unfollow businesses"
    ON follows FOR DELETE
    USING (auth.uid() = follower_id);

-- ============================================
-- SUBSCRIPTIONS POLICIES
-- ============================================

-- Business owners can view their own subscriptions
CREATE POLICY "Business owners can view their own subscriptions"
    ON subscriptions FOR SELECT
    USING (
        auth.uid() IN (SELECT owner_id FROM businesses WHERE id = subscriptions.business_id)
    );

-- Business owners can manage their subscriptions
CREATE POLICY "Business owners can manage subscriptions"
    ON subscriptions FOR ALL
    USING (
        auth.uid() IN (SELECT owner_id FROM businesses WHERE id = subscriptions.business_id)
    );

-- ============================================
-- NOTIFICATIONS POLICIES
-- ============================================

-- Users can view their own notifications
CREATE POLICY "Users can view their own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update their own notifications"
    ON notifications FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- System can insert notifications
CREATE POLICY "System can insert notifications"
    ON notifications FOR INSERT
    WITH CHECK (true);

-- ============================================
-- REPORTS POLICIES
-- ============================================

-- Users can view their own reports
CREATE POLICY "Users can view their own reports"
    ON reports FOR SELECT
    USING (auth.uid() = reporter_id OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'admin'));

-- Authenticated users can create reports
CREATE POLICY "Authenticated users can create reports"
    ON reports FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

-- Only admins can update reports
CREATE POLICY "Only admins can update reports"
    ON reports FOR UPDATE
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_type = 'admin'));

-- ============================================
-- SEED DATA
-- ============================================

-- Insert default categories
INSERT INTO categories (name, slug, icon, description) VALUES
('Restaurants', 'restaurants', '🍽️', 'Dining and food services'),
('Retail', 'retail', '🛍️', 'Shops and stores'),
('Services', 'services', '🔧', 'Professional services'),
('Health & Wellness', 'health-wellness', '💪', 'Healthcare and fitness'),
('Entertainment', 'entertainment', '🎭', 'Entertainment and events'),
('Education', 'education', '📚', 'Educational services'),
('Beauty & Spa', 'beauty-spa', '💅', 'Beauty and spa services'),
('Automotive', 'automotive', '🚗', 'Auto services and repairs');

-- Migration complete
