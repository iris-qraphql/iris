{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Language.Iris.Types.Internal.AST.Union
  ( UnionTypeDefinition,
    Variant (..),
  )
where

import Data.Mergeable (NameCollision (..))
import Data.Mergeable.Utils (KeyOf (..))
import Language.Haskell.TH.Syntax (Lift (..))
import Language.Iris.Rendering.RenderGQL
  ( RenderGQL (..),
  )
import Language.Iris.Types.Internal.AST.Base (Description)
import Language.Iris.Types.Internal.AST.Error
  ( GQLError,
    Msg (..),
    msg,
  )
import Language.Iris.Types.Internal.AST.Fields (FieldsDefinition)
import Language.Iris.Types.Internal.AST.Name
  ( TypeName,
  )
import Language.Iris.Types.Internal.AST.Stage
  ( Stage,
  )
import Language.Iris.Types.Internal.AST.Role
  ( Role,
  )
import Relude hiding (empty)

data Variant (cat :: Role) (s :: Stage) = Variant
  { memberDescription :: Maybe Description,
    memberName :: TypeName,
    membership :: Maybe TypeName,
    memberFields :: FieldsDefinition cat s
  }
  deriving (Show, Lift, Eq)

instance NameCollision GQLError (Variant c s) where
  nameCollision Variant {memberName} =
    "There can Be only one union variant named "
      <> msg memberName

type UnionTypeDefinition c s = NonEmpty (Variant c s)

instance RenderGQL (Variant cat s) where
  renderGQL Variant {memberName, memberFields} =
    renderGQL memberName <> renderGQL memberFields

instance Msg (Variant cat s) where
  msg = msg . memberName

instance KeyOf TypeName (Variant cat s) where
  keyOf = memberName
