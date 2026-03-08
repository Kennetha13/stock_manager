# Flutter Stock Manager

A multi-tenant inventory and workforce management mobile app built with **Flutter** and **Firebase**, designed for restaurants and small businesses to manage stock, employee access, and shift logging in one centralized platform.

## Overview

Flutter Stock Manager helps businesses organize and monitor operational data across separate company accounts. Managers can create and manage their own company workspace, track inventory, and oversee employee activity, while employees can securely log work hours and tips within the correct business environment.

This project is currently in progress and is being developed as a scalable mobile solution with role-based access and cloud-backed data storage.

## Features

- **Role-based access**
  - Manager and employee user flows
  - Separate dashboards and permissions for each role

- **Multi-tenant company structure**
  - Each manager can create and manage a unique company
  - Company data is isolated so each business has its own products, employees, and logs

- **Inventory management**
  - Add, edit, delete, and search products
  - Track product names and quantities in real time

- **Employee time logging**
  - Employees can submit worked hours and tips
  - Logs are associated with their company and profile

- **Firebase Authentication**
  - Secure login and account creation
  - Supports role-based user management

- **Cloud Firestore integration**
  - Stores company, employee, inventory, and log data
  - Real-time backend support for scalable updates

## Tech Stack

- **Frontend:** Flutter, Dart
- **Backend / Database:** Firebase Firestore
- **Authentication:** Firebase Authentication
- **Architecture Focus:** Multi-tenant data modeling, role-based access control, scalable cloud data organization

## Why This Project

Many restaurants and small businesses still rely on fragmented tools or manual processes to manage inventory and employee records. This project aims to simplify those workflows by combining:

- inventory tracking,
- employee management,
- shift logging,
- and company-specific data separation

into one mobile application.


## Example Firestore Structure

```text
companies/
  {companyId}/
    info/
    products/
    employees/
    time_logs/

users/
  {userId}
    - role
    - companyId
    - name
    - email
