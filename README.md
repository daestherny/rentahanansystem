# RENtahanan

RENtahanan is a Flutter apartment-management prototype backed by on-device
SQLite.

## Run

```powershell
flutter pub get
flutter run
```

## Current account flows

- **Landlord:** Create the local superadmin password on first use from the
  Welcome screen's **Superadmin** link. The superadmin can provision at most
  two landlord accounts, set each landlord's password, assign each a landlord
  ID, and save the apartment name, address, floor count, and unit count.
  Landlords sign in with their assigned ID and password.
- **Guest:** Browse available rooms, choose **View**, enter a name and
  password, select a viewing date and time, and submit the request. The guest
  receives a compact Guest ID and can sign in to track request status. Guest
  room details also show previous renter ratings and feedback.
- **Landlord review:** Review guest viewing requests in Explore, approve or
  reject a viewing, and accept an approved guest as a tenant. Active tenant
  profiles and payment records are available in Explore; landlords can record
  rent dues and mark payments as paid. Landlords can attach up to five room
  photos when
  adding a listing and attach a contract image when accepting a tenant.
  Announcements are shown at the top of the dashboard, and landlords can review
  monthly sales and annual net collected payments from the dashboard.
  The landlord dashboard places announcements first, editable property cards
  second, and a monthly collections graph with financial summary third. Room
  photos are stored as app-managed files to avoid oversized SQLite rows.
  Tenant ratings, feedback, and suggestions are also available on the landlord
  dashboard after a contract ends. The landlord Messages inbox combines tenant
  conversations with guest viewing requests and messages, with unread, current
  tenant, and viewing guest filters.
- **Tenant:** A newly accepted guest must acknowledge guest-account deletion
  and activate the compact assigned Tenant ID with their personal information and
  acceptance of the Terms & Conditions. Tenants and guests can view room photos
  while browsing, and tenants can view their contract image in My Contract.
  Tenant dashboards show announcements from their landlord near the top. When
  a contract expires, the tenant is notified and prompted to leave a rating,
  feedback, and optional suggestions. Tenants with no active contract can keep
  their account to browse rooms and message landlords, or deactivate it while
  retaining historical rental records.
- **Confirmations:** Logging out, removing a room or announcement, and
  terminating a contract require explicit confirmation.
- **Viewing schedules:** Landlords can block recurring weekdays, specific
  dates, or entire months in Explore > Viewing Availability. Guests and tenants
  can request viewings only on available dates and between 8:00 AM and 6:00 PM.

The sales report counts paid payment records only; outstanding dues are
excluded. Operating expenses are not tracked, so the annual net collected
value is not a profit-after-expenses calculation.

## Prototype security and storage

This project stores accounts, passwords, requests, and rental data in a local
SQLite database. The first-run superadmin setup is not a secure identity or
authorization service: anyone with access to the app/device can reach local
setup and data. Passwords are not protected by a production-grade server-side
authentication system. Before real deployment, use a trusted backend, secure
password hashing, and server-enforced landlord/superadmin authorization.

The app no longer seeds demo landlord or tenant accounts on a fresh database.
Existing local databases are migrated when the app is upgraded.
