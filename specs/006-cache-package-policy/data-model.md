# Data Model: Cache and Package Policy

The declarative policy has three immutable ordered lists:

- cache substituter URLs;
- trusted cache public keys; and
- exact allowed unfree package names.

The unfree predicate returns true only when `lib.getName package` belongs to the third list.
