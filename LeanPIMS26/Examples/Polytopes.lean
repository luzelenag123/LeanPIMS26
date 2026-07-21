import mathlib.tactic

namespace LeanW26

set_option linter.style.emptyLine false
set_option linter.style.whitespace false

#eval Lean.versionString

--  Copyright (C) 2025  Eric Klavins
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

/-
Polytopes --Luz Elena Grisales Gómez
===
-/

/-
Overview
===

One can represent polytopes in two ways:

- As the convex hull of finitely many points. In this case, we refer to it as a `V-polytope`.

- As the bounded intersection of finitely many closed halfspaces. In this case, we refer to it as an `H-polytope`.

These two representations are equivalent due to the `Minkowski-Weyl Theorem`.

-/

/-
Set up
===
We'll need to perform pointwise operations and use noncomputable constructions (e.g. axiom of choice). For this, we will use:
-/
-- using `scoped` below imports only the notation.
open scoped Pointwise
noncomputable section
/-
We'll also need to define the space in which our polytopes will live:
-/
variable {E : Type*}
[NormedAddCommGroup E] [InnerProductSpace ℝ E]
[FiniteDimensional ℝ E] [DecidableEq E]

/-
Defining V-Polytopes
===
We can define V-Polytopes as a structure storing its set of generating points.
-/
structure VPolytope (E : Type*)
  [DecidableEq E]
  [NormedAddCommGroup E]
  [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E]
where
  points : Finset E

/-
The VPolytope namespace
===
Now we can add a few definitions directly associated to a VPolytope:
-/
namespace VPolytope

/-- Underlying set associated to the `VPolytope` structure. -/
def carrier (P : VPolytope E) : Set E :=
  convexHull ℝ (↑P.points : Set E)

/-- VPolytope resulting from translating `P` by vector `v`. -/
def translate (P : VPolytope E) (v : E) : VPolytope E :=
  ⟨v +ᵥ P.points⟩
/-
The definitions and theorems written inside this namespace can be accessed from outside the namespace by writting `VPolytope.{definition\theorem}`.
-/
/-
Proving isCompact, isConvex
===
We can write simple theorems like the following inside this namespace.
-/
theorem isCompact (P : VPolytope E) : IsCompact P.carrier := by
  simpa [carrier] using
      (Set.Finite.isCompact_convexHull
        (s := (↑P.points : Set E))
        (P.points.finite_toSet))

theorem isConvex (P : VPolytope E) : Convex ℝ P.carrier := by
  simpa [VPolytope.carrier] using
          (convex_convexHull ℝ (↑P.points : Set E))

end VPolytope
/-
Exercise
===
Search Mathlib's `Compact.lean` file for theorems that help prove `isClosed P` and `isBounded P` in just one line.

```lean
theorem isBounded (P : VPolytope E) : Bornology.IsBounded P.carrier := by
  sorry
theorem isClosed (P : VPolytope E) : IsClosed P.carrier := by
  sorry
```
-/
/-
Halfspaces
===
We can naturally define a halfspace as follows:
-/
structure Halfspace (E : Type*)
  [DecidableEq E]
  [NormedAddCommGroup E]
  [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E]
where
  normal : E
  offset : ℝ
/-
The Halfspace namespace
===
Inside the Halfspace namespace we can define the carrier to be:
-/
namespace Halfspace

def carrier (h : Halfspace E) : Set (E) :=
  {x | inner ℝ h.normal x ≤ h.offset}

-- We can also prove that a Halfspace is `isClosed` as follows
theorem isClosed (H : Halfspace E) : IsClosed H.carrier := by
  dsimp [carrier]
  apply isClosed_le
  · exact continuous_const.inner continuous_id
  · exact continuous_const
/-
Exercise
===
Use the help of AI to generate a prove for `isConvex`.
```lean
theorem isConvex (H : Halfspace E) : Convex ℝ H.carrier := by
  sorry
```
-/

/-
Inferring DecidableEq
===
`DecidableEq` is a typeclass in Lean. To tell Lean that the `Halfspace` type has decidable equality, we need to instantiate this typeclass.

Lean can sometimes infer the instance using the tactic `infer_instance`:
-/
instance [DecidableEq E] : DecidableEq (Halfspace E) := by
  classical
  infer_instance
/- We need `DecidableEq` in order to be able to create sets of halfspaces.-/
end Halfspace
/-

H-Polyhedra
===

An `H-Polyhedron` is a finite intersection of halfspaces. An `H-Polytope` is an H-Polyhedron that is also bounded. In Lean, we can encode this as follows:
-/
structure HPolyhedron (E : Type*)
  [DecidableEq E]
  [NormedAddCommGroup E]
  [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E]
where
  (halfspaces : Finset (Halfspace E))

/-
The HPolyhedron namespace
===
-/
namespace HPolyhedron

def carrier (P : HPolyhedron E) : Set E :=
  ⋂ h ∈ P.halfspaces, (h.carrier)
/-
For proving the Minkwoski-Weyl Theorem, we also need to include theorems like `isConvex` and `isClosed` inside this namespace, but for this presentation we'll skip them.

`Challenge:` Define how to translate an HPolyhedron.
-/
def translate (P : HPolyhedron E) (v : E) : HPolyhedron E :=
  sorry

end HPolyhedron

/-
H-Polytopes
===
Since an H-Polytope is an H-Polyhedron with additional conditions, we can use `extends` in Lean.
-/

structure HPolytope (E : Type*)
  [DecidableEq E]
  [NormedAddCommGroup E]
  [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E]
extends HPolyhedron E where
  (bounded : Bornology.IsBounded (toHPolyhedron.carrier))
/-
An `HPolytope` will inherit definitions and theorems defined for an `HPolyhedron`.
-/

/-
Duality
===
A key tool in prove the Minkowski-Weyl Theorem is duality.

Some version of duality is already implemented in Mathlib, but it is too general and difficult to parse for our purposes, so we implement our own:
-/
def dual (P : Set E) : Set E :=
  ⋂ x ∈ (P \ {0}), (Halfspace.mk x 1).carrier
/-
Exercise
===
Prove the following basic properties of duality.
-/
namespace dual

theorem zero_mem (P : Set E) : (0 : E) ∈ dual P := by
  sorry
theorem isAntitone {A B : Set E} (h : A ⊆ B) : dual B ⊆ dual A := by
  sorry

end dual
/-
It is also true that the dual of a set of is closed and convex, and should follow directly from the Halfspace properties.
-/

/-
The dual of a VPolytope
===
One can observe directly from the definition of duality the the dual of a VPolytope is an HPolyhedron (because points become halfspaces).

Therefore, we can define the dual of a `VPolytope` as:
-/
def VPolytope.dual (P : VPolytope E) : HPolyhedron E :=
  { halfspaces := P.points.image (fun x => Halfspace.mk x 1) }
/-
A natural theorem would then be:
-/
theorem dual_of_VPolytope (P : VPolytope E) : dual P.carrier = P.dual.carrier := sorry
/-
This is a long Lean proof, so we are not doing it today. If you want, you can try to generate a proof using AI.
-/

/-
Main Theorems
===
Some of the main theorems we want to prove in order to establish the equivalence between VPolytopes and HPolytope include:
-/
theorem separation_compact_closed
    {C D : Set E}
    (hC_nonempty : C.Nonempty)
    (hC_convex : Convex ℝ C) (hC_compact : IsCompact C)
    (hD_nonempty : D.Nonempty)
    (hD_convex : Convex ℝ D) (hD_closed : IsClosed D)
    (hdisj : Disjoint C D) :
    ∃ (a : E) (b : ℝ),
      a ≠ 0 ∧
      C ⊆ {x | inner ℝ a x < b} ∧
      D ⊆ {x | inner ℝ a x > b} := sorry

/-
Main Theorems (continued)
-/
theorem dual_of_dual
  (X : Set E) :
  dual (dual X)
    = closure (convexHull ℝ (Set.union X ({0} : Set E))) := sorry

theorem HPolytope_is_VPolytope : ∀ P : HPolytope E, ∃ Q : VPolytope E, P.carrier = Q.carrier := sorry

theorem VPolytope_is_HPolytope [Nontrivial E] : ∀ P : VPolytope E, ∃ Q : HPolytope E, P.carrier = Q.carrier := sorry

--hide
end
end LeanW26
--unhide
