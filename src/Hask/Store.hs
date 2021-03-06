{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}
--------------------------------------------------------------------
-- |
-- Copyright :  (c) Edward Kmett 2008-2014
-- License   :  BSD3
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable
--
--------------------------------------------------------------------
module Hask.Store where

import Hask.Core

-- more general indexing is possible. how should we explore them?

type family Store :: i -> i -> i

data Store0 s a = Store (s -> a) s
type instance Store = Store0

instance Functor (Store0 s) where
  fmap f (Store g s) = Store (f . g) s

instance Cosemimonad (Store0 s) where
  duplicate (Store f s) = Store (Store f) s

instance Comonad (Store0 s) where
  extract (Store f s) = f s

-- indexed store
data Store1 s a i = Store1 (s ~> a) (s i)
type instance Store = Store1

instance Functor (Store1 s) where
  fmap f = Nat $ \(Store1 g s) -> Store1 (f . g) s

instance Cosemimonad (Store1 s) where
  duplicate = Nat $ \(Store1 f s) -> Store1 (Nat $ Store1 f) s

instance Comonad (Store1 s) where
  extract = Nat $ \(Store1 f s) -> runNat f s
