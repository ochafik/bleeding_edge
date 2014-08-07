bleeding_edge
=============

Best Effort syncing, no guarantees. A read-only mirror of dart.googlecode.com. Please don't send Pull Requests here, please contribute via:

# Solver experiments

- Eagerly fetch metadata of all packages ever needed, recursively, for each version.
- Explore solution space iteratively, at every step choose the dimension (package) with the smallest search space (number of valid versions based on current constraints). Immutable constraints with efficient immutable sets (i.e. w/ efficient add) are crucial here to compose constraints at every step.
- For each chosen dimension, start by most recent valid version V and propagage the search with interval [V - epsilon(package), V]. That epsilon(package) will be constrained at every next step and returned when the solve completes or fails. When failed, the next step on this dimention is to pick V' = V - epsilon - 1.
- At every step, intersect current constraints with constraints of the picked version. If reduce epsilon until constraints are the same.
