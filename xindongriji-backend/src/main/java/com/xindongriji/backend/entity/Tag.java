/**
 * BEGINNER GUIDE:
 * File: Tag.java
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
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "tags", uniqueConstraints = {
    @UniqueConstraint(name = "uk_tag_user_name", columnNames = {"user_id", "name"})
})
public class Tag {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, length = 30)
  private String name;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_tag_user"))
  private User user;

  @ManyToMany(mappedBy = "tags")
  private Set<Diary> diaries = new HashSet<>();

  @CreationTimestamp
  @Column(updatable = false)
  private Instant createdAt;

  @UpdateTimestamp
  private Instant updatedAt;
}
