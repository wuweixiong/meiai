/**
 * BEGINNER GUIDE:
 * File: User.java
 * Role: Domain entity: maps business objects to database tables.
 * Reading tip: Start from public methods, then follow called services/repositories.
 */

package com.xindongriji.backend.entity;

import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.time.Instant;

@Getter
@Setter
@Entity
@Table(name = "users", uniqueConstraints = {
    @UniqueConstraint(name = "uk_user_phone", columnNames = "phone")
})
public class User {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, length = 20)
  private String phone;

  @Column(nullable = false, length = 100)
  private String passwordHash;

  @CreationTimestamp
  @Column(updatable = false)
  private Instant createdAt;

  @UpdateTimestamp
  private Instant updatedAt;
}
