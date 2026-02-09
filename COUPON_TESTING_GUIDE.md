# Coupon Feature - Testing & Integration Guide

## 🚀 Quick Start

The coupon feature is now fully implemented and ready to test!

---

## 📋 Prerequisites

### Backend Requirements:
Your backend must implement these endpoints:

```
GET  /api/v1/coupons                  - List available coupons
GET  /api/v1/coupons/{code}           - Get specific coupon
POST /api/v1/coupons/validate         - Validate coupon
POST /api/v1/orders/cart/coupon       - Apply coupon to cart (already working)
DELETE /api/v1/orders/cart/coupon     - Remove coupon (already working)
```

---

## 🧪 Testing the Implementation

### 1. Manual Testing Flow

#### Step 1: Start the App
```bash
flutter run
```

#### Step 2: Add Items to Cart
1. Navigate to menu
2. Add some items to cart
3. Open cart screen

#### Step 3: Test Coupon Bottom Sheet
1. Click "Apply Coupon" button
2. Bottom sheet should open
3. You should see:
   - Loading indicator while fetching coupons
   - List of available coupons (from API)
   - OR error message if API fails
   - OR "No coupons available" if empty

#### Step 4: Test Apply Coupon
**Option A: Select from List**
1. Tap "Apply" on any coupon card
2. Should see success message
3. Discount should appear in cart
4. Coupon should show "Applied" badge

**Option B: Manual Entry**
1. Type coupon code in text field
2. Tap "Apply" button
3. Should see success message
4. Discount should appear in cart

#### Step 5: Test Remove Coupon
1. Tap the X icon on applied coupon
2. Discount should be removed
3. Cart total should update

#### Step 6: Test Pull-to-Refresh
1. Pull down on coupon list
2. Should show refresh indicator
3. Should reload coupons from API

---

## 🔧 Backend Mock Data (For Testing)

If your backend is not ready, here's sample data it should return:

### GET /api/v1/coupons Response:
```json
{
  "success": true,
  "message": "Coupons retrieved successfully",
  "data": [
    {
      "coupon_id": 1,
      "code": "SAVE10",
      "type": "PERCENTAGE",
      "discount_value": 10.0,
      "minimum_order_amount": 20.0,
      "maximum_discount_amount": 15.0,
      "valid_from": "2026-01-01T00:00:00Z",
      "valid_until": "2026-12-31T23:59:59Z",
      "max_uses_per_user": 5,
      "total_max_uses": 1000,
      "current_uses": 543,
      "applicable_kitchen_ids": null,
      "is_active": true,
      "description": "Get 10% off on your order",
      "created_at": "2026-01-01T00:00:00Z",
      "updated_at": "2026-01-01T00:00:00Z"
    },
    {
      "coupon_id": 2,
      "code": "FREESHIP",
      "type": "FREE_DELIVERY",
      "discount_value": 0.0,
      "minimum_order_amount": 30.0,
      "maximum_discount_amount": null,
      "valid_from": "2026-01-01T00:00:00Z",
      "valid_until": "2026-12-31T23:59:59Z",
      "max_uses_per_user": null,
      "total_max_uses": null,
      "current_uses": 0,
      "applicable_kitchen_ids": null,
      "is_active": true,
      "description": "Free delivery on orders above RM30",
      "created_at": "2026-01-01T00:00:00Z",
      "updated_at": "2026-01-01T00:00:00Z"
    },
    {
      "coupon_id": 3,
      "code": "SAVE5",
      "type": "FIXED_AMOUNT",
      "discount_value": 5.0,
      "minimum_order_amount": 25.0,
      "maximum_discount_amount": null,
      "valid_from": "2026-01-01T00:00:00Z",
      "valid_until": "2026-06-30T23:59:59Z",
      "max_uses_per_user": 3,
      "total_max_uses": 500,
      "current_uses": 234,
      "applicable_kitchen_ids": [1, 2, 3],
      "is_active": true,
      "description": "Save RM5 on your next order",
      "created_at": "2026-01-01T00:00:00Z",
      "updated_at": "2026-01-01T00:00:00Z"
    }
  ]
}
```

### POST /api/v1/coupons/validate Response:
```json
{
  "success": true,
  "message": "Coupon is valid",
  "data": {
    "is_valid": true,
    "message": "Coupon SAVE10 applied successfully",
    "discount_amount": 5.0,
    "coupon": {
      "coupon_id": 1,
      "code": "SAVE10",
      "type": "PERCENTAGE",
      "discount_value": 10.0,
      "description": "Get 10% off on your order"
    }
  }
}
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Failed to load coupons"
**Cause:** Backend endpoint not available or returning error
**Solution:** 
- Check backend is running
- Verify endpoint URL is correct
- Check network connectivity
- Review backend logs

### Issue 2: No coupons showing
**Cause:** Backend returns empty array or no coupons match criteria
**Solution:**
- Check backend has coupons in database
- Verify coupons are active
- Check kitchen filtering
- Try without kitchen filter

### Issue 3: Cannot apply coupon
**Cause:** Apply endpoint failing
**Solution:**
- Already implemented and working
- Check cart has items
- Verify coupon code is correct
- Check backend validation rules

### Issue 4: Loading forever
**Cause:** API timeout or no response
**Solution:**
- Check network connection
- Increase timeout in ApiService
- Check backend response time
- Review backend logs

---

## 📱 UI States to Verify

### ✅ Loading State
```
Shows: Circular progress indicator
When: Fetching coupons from API
```

### ✅ Success State
```
Shows: List of coupon cards
When: API returns coupons
Features:
- Coupon code badge
- Discount display
- Description
- Min order requirement
- Valid until date
- Apply button
```

### ✅ Error State
```
Shows: Error icon + message + Retry button
When: API call fails
Action: Retry button refetches
```

### ✅ Empty State
```
Shows: Empty icon + "No coupons available"
When: API returns empty array
```

### ✅ Applied State
```
Shows: Green badge with "Applied" text
When: Coupon is currently applied to cart
```

---

## 🔍 Debug Checklist

### Before Testing:
- [ ] Backend endpoints implemented
- [ ] Backend returning mock/real coupon data
- [ ] API gateway routing configured
- [ ] Auth tokens working
- [ ] Network reachable

### During Testing:
- [ ] Check Flutter console for API logs
- [ ] Verify API requests being sent
- [ ] Check API responses
- [ ] Verify error messages shown
- [ ] Check loading indicators appear

### Backend Verification:
```bash
# Test coupon list endpoint
curl -X GET http://localhost:8080/api/v1/coupons \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test specific coupon
curl -X GET http://localhost:8080/api/v1/coupons/SAVE10 \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test validation
curl -X POST http://localhost:8080/api/v1/coupons/validate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"code":"SAVE10","kitchen_id":1,"order_amount":50.0}'
```

---

## 📊 Test Scenarios

### Scenario 1: Happy Path
1. ✅ Open cart with items
2. ✅ Click "Apply Coupon"
3. ✅ See loading indicator
4. ✅ See list of coupons
5. ✅ Tap "Apply" on a coupon
6. ✅ See success message
7. ✅ See discount in cart
8. ✅ Proceed to checkout

### Scenario 2: Manual Entry
1. ✅ Open coupon bottom sheet
2. ✅ Type "SAVE10" in text field
3. ✅ Tap "Apply" button
4. ✅ See success message
5. ✅ Discount appears in cart

### Scenario 3: Invalid Coupon
1. ✅ Type "INVALID" in text field
2. ✅ Tap "Apply"
3. ✅ See error message: "Coupon not found"
4. ✅ No discount applied

### Scenario 4: Expired Coupon
1. ✅ Try to apply expired coupon
2. ✅ See error: "Coupon has expired"
3. ✅ No discount applied

### Scenario 5: Minimum Order Not Met
1. ✅ Cart total: RM15
2. ✅ Try to apply coupon with min RM20
3. ✅ See error: "Minimum order RM20 required"
4. ✅ No discount applied

### Scenario 6: Kitchen Mismatch
1. ✅ Cart has items from Kitchen A
2. ✅ Try to apply coupon for Kitchen B only
3. ✅ See error: "Coupon not applicable"
4. ✅ No discount applied

### Scenario 7: Remove Coupon
1. ✅ Apply a coupon
2. ✅ See discount
3. ✅ Tap X to remove
4. ✅ Discount removed
5. ✅ Cart total updated

### Scenario 8: Pull to Refresh
1. ✅ Open coupon list
2. ✅ Pull down
3. ✅ See refresh indicator
4. ✅ List reloads from API
5. ✅ New/updated coupons appear

### Scenario 9: Network Error
1. ✅ Disable network
2. ✅ Open coupon sheet
3. ✅ See error state
4. ✅ Tap "Retry"
5. ✅ Enable network
6. ✅ Coupons load successfully

### Scenario 10: Empty Coupons
1. ✅ Backend returns empty array
2. ✅ See "No coupons available"
3. ✅ Pull to refresh works
4. ✅ Can still enter code manually

---

## 🎯 Performance Considerations

### Caching Strategy:
```dart
// Coupons are cached after first load
// Only refetches when:
1. User pulls to refresh
2. Kitchen ID changes
3. Force refresh called
4. Cache is stale (> 5 minutes)
```

### API Call Optimization:
```dart
// Prevents unnecessary API calls:
if (hasCoupons && !forceRefresh && sameKitchen) {
  return; // Use cached data
}
```

---

## 📝 Integration Notes

### For Backend Developers:

1. **Coupon Types:**
   - `PERCENTAGE`: discount_value is percentage (10 = 10%)
   - `FIXED_AMOUNT`: discount_value is currency amount (5 = RM5)
   - `FREE_DELIVERY`: Sets delivery fee to 0

2. **Kitchen Filtering:**
   - If `applicable_kitchen_ids` is null/empty: Available to all
   - If array has IDs: Only available to those kitchens

3. **Validation Rules:**
   - Check `is_active` = true
   - Check current date between `valid_from` and `valid_until`
   - Check `current_uses` < `total_max_uses` (if not null)
   - Check `minimum_order_amount` <= cart total
   - Check kitchen match if specified

4. **Response Format:**
   - Always return standard format: `{success, message, data}`
   - Use snake_case for field names
   - Return ISO 8601 dates
   - Include error messages in `message` field

---

## 🔐 Security Considerations

### User Context:
- All API calls include `Authorization` header
- Backend should verify user authentication
- Backend should track per-user usage

### Rate Limiting:
- Consider rate limiting coupon validation
- Prevent brute force coupon guessing
- Log suspicious activity

### Coupon Code Security:
- Use random, hard-to-guess codes
- Avoid sequential codes (SAVE1, SAVE2, etc.)
- Consider code expiry after X failed attempts

---

## 📚 Code References

### Key Files:
```
lib/
├── core/
│   ├── models/
│   │   └── coupon_model.dart          ← Coupon data model
│   ├── services/
│   │   └── api_service.dart           ← API methods (lines 401-429)
│   └── config/
│       └── app_config.dart            ← Endpoint config (line 33)
└── features/
    └── cart/
        ├── providers/
        │   ├── cart_provider.dart     ← Apply/remove logic
        │   └── coupon_provider.dart   ← Coupon state management
        ├── screens/
        │   └── cart_screen.dart       ← Cart UI with coupon section
        └── widgets/
            └── coupon_bottom_sheet.dart ← Coupon selection UI
```

### Important Methods:
```dart
// Fetch coupons
CouponProvider.fetchAvailableCoupons({kitchenId})

// Apply coupon
CartProvider.applyCoupon(code)

// Remove coupon
CartProvider.removeCoupon()

// Validate coupon
CouponProvider.validateCoupon({code, kitchenId, orderAmount})
```

---

## ✅ Final Checklist

### Before Production:
- [ ] Backend endpoints tested and working
- [ ] Error messages are user-friendly
- [ ] Loading states appear correctly
- [ ] Empty states show properly
- [ ] Applied coupons display correctly
- [ ] Discount calculations accurate
- [ ] Can remove coupons successfully
- [ ] Pull-to-refresh works
- [ ] Kitchen filtering works
- [ ] Expired coupons rejected
- [ ] Usage limits enforced
- [ ] Minimum orders validated
- [ ] Analytics tracking implemented (optional)

### Performance:
- [ ] API responses < 1 second
- [ ] Caching works correctly
- [ ] No unnecessary API calls
- [ ] UI smooth and responsive
- [ ] No memory leaks

### Documentation:
- [ ] API documentation updated
- [ ] Backend integration guide ready
- [ ] Error codes documented
- [ ] Test cases documented

---

## 🎉 Ready to Test!

All code is implemented and ready. Follow the testing flow above to verify everything works as expected.

**Need Help?**
- Check Flutter console for API logs
- Review backend response format
- Verify authentication tokens
- Check network connectivity

**Good luck! 🚀**

